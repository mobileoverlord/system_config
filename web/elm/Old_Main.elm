module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Dict
import WebSocket
import Json.Encode as JE
import Json.Decode as JD exposing (Decoder, dict)
import Json.Decode.Pipeline exposing (optional, required, decode)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.ListGroup as ListGroup


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type JsVal
    = JsString String
    | JsInt Int
    | JsFloat Float
    | JsArray (List JsVal)
    | JsObject RegistryNode
    | JsNull


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , debugMessages : List String
    , registryGlobal : JsVal
    , breadcrumb : List String
    }


type alias RegistryNode =
    Dict.Dict String JsVal


type alias RegistryNodeKey =
    String


initPhxSocket : String -> Phoenix.Socket.Socket Msg
initPhxSocket url =
    Phoenix.Socket.init url
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "global" "registry" ReceiveRegistryMessage


initRegistryNode : JsVal
initRegistryNode =
    JsObject Dict.empty


init : ( Model, Cmd Msg )
init =
    let
        startPhxSocket =
            initPhxSocket "ws://localhost:4000/socket/websocket"

        debugMessages =
            []

        registryGlobal =
            initRegistryNode

        registryChannel =
            Phoenix.Channel.init "registry"
                |> Phoenix.Channel.onJoin (OnChannelJoin "registry")
                |> Phoenix.Channel.onJoinError (OnChannelJoinError "registry")
                |> Phoenix.Channel.onError (OnChannelError "registry")
                |> Phoenix.Channel.onClose (OnChannelClose "registry")

        ( phxSocket, registryCmd ) =
            Phoenix.Socket.join registryChannel startPhxSocket
    in
        ( { debugMessages = debugMessages
          , registryGlobal = registryGlobal
          , phxSocket = phxSocket
          , breadcrumb = [ "system" ]
          }
        , Cmd.batch [ Cmd.map PhxSocketMessage registryCmd ]
        )


type Msg
    = PhxSocketMessage (Phoenix.Socket.Msg Msg)
    | OnChannelJoin String JE.Value
    | OnChannelJoinError String JE.Value
    | OnChannelError String JE.Value
    | OnChannelClose String JE.Value
    | ReceiveRegistryMessage JE.Value
    | BreadcrumbNavigate (List String)


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
            case JD.decodeValue registryMessageDecoder json of
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
            case JD.decodeValue registryMessageDecoder json of
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

        BreadcrumbNavigate scope ->
            ( { model
                | debugMessages = (("Breadcrumb Clicked: " ++ toString scope) :: model.debugMessages)
                , breadcrumb = (scope ++ model.breadcrumb)
              }
            , Cmd.none
            )


registryMessageDecoder : Decoder JsVal
registryMessageDecoder =
    JD.oneOf
        [ JD.string |> JD.andThen (JD.succeed << JsString)
        , JD.int |> JD.andThen (JD.succeed << JsInt)
        , JD.float |> JD.andThen (JD.succeed << JsFloat)
        , JD.list (JD.lazy (\_ -> registryMessageDecoder)) |> JD.andThen (JD.succeed << JsArray)
        , JD.dict (JD.lazy (\_ -> registryMessageDecoder)) |> JD.andThen (JD.succeed << JsObject)
        , JD.null JsNull
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Phoenix.Socket.listen model.phxSocket PhxSocketMessage
        ]


view : Model -> Html Msg
view model =
    div [ class "navigation" ]
        [ CDN.stylesheet
        , ol [ class "breadcrumb" ]
            (renderBreadcrumb model.breadcrumb)
        , Grid.container []
            [ ListGroup.ul
                (renderBranch model.registryGlobal)
            ]
        ]


renderBreadcrumb : List String -> List (Html Msg)
renderBreadcrumb scope =
    scope
        |> List.reverse
        |> List.map
            (\p ->
                li []
                    [ a [ href "#", onClick (BreadcrumbNavigate [ p ]) ] [ text p ]
                    ]
            )


renderNode : String -> JsVal -> ListGroup.Item Msg
renderNode key value =
    case value of
        JsString value ->
            ListGroup.li []
                [ text (toString value) ]

        JsInt value ->
            ListGroup.li []
                [ text (toString value) ]

        JsFloat value ->
            ListGroup.li []
                [ text (toString value) ]

        JsArray value ->
            ListGroup.li []
                [ text (toString value) ]

        JsObject obj ->
            ListGroup.li []
                [ a [ href "#", onClick (BreadcrumbNavigate [ key ]) ] [ text key ]
                ]

        JsNull ->
            ListGroup.li []
                [ text "nil" ]


renderBranch : JsVal -> List (ListGroup.Item Msg)
renderBranch branch =
    case branch of
        JsObject obj ->
            Dict.toList obj
                |> List.map
                    (\( k, v ) ->
                        (renderNode k v)
                    )

        _ ->
            [ ListGroup.li [] [] ]



--|> List.map (\val -> renderNode val)
