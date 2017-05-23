module Nerves.SystemConfig.Subscriptions exposing (subscriptions)

import Nerves.SystemConfig.Model exposing (Model)
import Nerves.SystemConfig.Messages exposing (Msg(..))
import Phoenix.Socket exposing (listen)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Phoenix.Socket.listen model.phxSocket PhxSocketMessage
        ]
