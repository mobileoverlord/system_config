module Nerves.SystemConfig.Update exposing (update)

import Nerves.SystemConfig.Model exposing (Model, registryNodeDecoder)
import Nerves.SystemConfig.Messages exposing (Msg(..))
import Phoenix.Socket exposing (update)
import Phoenix.Push
import Json.Decode as JD
import Json.Encode as JE
import Dict


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhxSocketMessage msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhxSocketMessage phxCmd
                )

        OnChannelJoin channelName json ->
            case JD.decodeValue registryNodeDecoder json of
                Ok registryMessage ->
                    ( { model
                        | registryGlobal = registryMessage
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model
                        | debugMessages = ("OnChannelJoin error: " ++ toString error) :: model.debugMessages
                      }
                    , Cmd.none
                    )

        OnChannelJoinError channelName json ->
            ( { model
                | debugMessages = ("OnChannelJoinError(" ++ channelName ++ "): " ++ toString json) :: model.debugMessages
              }
            , Cmd.none
            )

        OnChannelError channelName json ->
            ( { model
                | debugMessages = ("OnChannelError(" ++ channelName ++ "): " ++ toString json) :: model.debugMessages
              }
            , Cmd.none
            )

        OnChannelClose channelName json ->
            ( { model
                | debugMessages = ("OnChannelClose(" ++ channelName ++ "): " ++ toString json) :: model.debugMessages
              }
            , Cmd.none
            )

        OnChannelPushError error ->
            ( { model
                | debugMessages = ("OnChannelPushError(" ++ toString error ++ ")") :: model.debugMessages
              }
            , Cmd.none
            )

        ReceiveRegistryMessage json ->
            case JD.decodeValue registryNodeDecoder json of
                Ok registryMessage ->
                    ( { model
                        | debugMessages = ("OnRegistryMessage: " ++ toString registryMessage) :: model.debugMessages
                        , registryGlobal = registryMessage
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model
                        | debugMessages = ("OnRegistryMessage error: " ++ toString error) :: model.debugMessages
                      }
                    , Cmd.none
                    )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        Navigate cwd ->
            ( { model
                | debugMessages = (("Navigate: " ++ toString cwd) :: model.debugMessages)
                , cwd = cwd
              }
            , Cmd.none
            )

        CacheValue key value ->
            ( { model
                | debugMessages = (("CacheValue: " ++ toString key ++ " " ++ toString value) :: model.debugMessages)
                , pendingChanges = Dict.insert key value model.pendingChanges
              }
            , Cmd.none
            )

        SaveValue key ->
            let
                scope =
                    (key
                        :: model.cwd
                    )
                        |> List.reverse
                        |> List.map (\item -> JE.string item)

                value =
                    case Dict.get key model.pendingChanges of
                        Nothing ->
                            ""

                        Just val ->
                            val

                payload =
                    JE.object
                        [ ( "scope", JE.list scope )
                        , ( "value", JE.string value )
                        ]

                phxPush =
                    Phoenix.Push.init "update" "registry"
                        |> Phoenix.Push.withPayload payload
                        |> Phoenix.Push.onOk ReceiveRegistryMessage
                        |> Phoenix.Push.onError OnChannelPushError

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push phxPush model.phxSocket
            in
                ( { model
                    | debugMessages = (("SaveValue: " ++ toString key) :: model.debugMessages)
                    , phxSocket = phxSocket
                  }
                , Cmd.map PhxSocketMessage phxCmd
                )
