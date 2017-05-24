module Nerves.SystemConfig.Messages exposing (Msg(..))

import Phoenix.Socket
import Json.Encode as JE
import Bootstrap.Navbar as Navbar


type Msg
    = PhxSocketMessage (Phoenix.Socket.Msg Msg)
    | OnChannelJoin String JE.Value
    | OnChannelJoinError String JE.Value
    | OnChannelError String JE.Value
    | OnChannelClose String JE.Value
    | OnChannelPushError JE.Value
    | ReceiveRegistryMessage JE.Value
    | NavbarMsg Navbar.State
    | Navigate (List String)
    | CacheValue String String
    | SaveValue String
