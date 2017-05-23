module Nerves.SystemConfig.Messages exposing (Msg(..))

import Phoenix.Socket
import Json.Encode as JE


type Msg
    = PhxSocketMessage (Phoenix.Socket.Msg Msg)
    | OnChannelJoin String JE.Value
    | OnChannelJoinError String JE.Value
    | OnChannelError String JE.Value
    | OnChannelClose String JE.Value
    | ReceiveRegistryMessage JE.Value
    | Navigate (List String)
