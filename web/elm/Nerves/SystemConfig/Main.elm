module Nerves.SystemConfig.Main exposing (main)

import Html exposing (Html)
import Nerves.SystemConfig.Messages exposing (Msg(..))
import Nerves.SystemConfig.Subscriptions exposing (subscriptions)
import Nerves.SystemConfig.Model exposing (Model, JsVal(..), RegistryNode)
import Nerves.SystemConfig.Update exposing (update)
import Nerves.SystemConfig.View exposing (view)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Dict


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
          , cwd = []
          }
        , Cmd.batch [ Cmd.map PhxSocketMessage registryCmd ]
        )


initPhxSocket : String -> Phoenix.Socket.Socket Msg
initPhxSocket url =
    Phoenix.Socket.init url
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "global" "registry" ReceiveRegistryMessage


initRegistryNode : RegistryNode
initRegistryNode =
    Dict.empty


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
