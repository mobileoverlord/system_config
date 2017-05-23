module Nerves.SystemConfig.Update exposing (update)

import Nerves.SystemConfig.Model exposing (Model, registryNodeDecoder)
import Nerves.SystemConfig.Messages exposing (Msg(..))
import Phoenix.Socket exposing (update)
import Json.Decode as JD


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

        ReceiveRegistryMessage json ->
            case JD.decodeValue registryNodeDecoder json of
                Ok registryMessage ->
                    ( { model
                        | registryGlobal = registryMessage
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model
                        | debugMessages = ("OnRegistryMessage error: " ++ toString error) :: model.debugMessages
                      }
                    , Cmd.none
                    )

        Navigate cwd ->
            ( { model
                | debugMessages = (("Navigate: " ++ toString cwd) :: model.debugMessages)
                , cwd = cwd
              }
            , Cmd.none
            )
