module Nerves.SystemConfig.Model exposing (Model, JsVal(..), registryMessageDecoder)

import Nerves.SystemConfig.Messages exposing (Msg)
import Phoenix.Socket exposing (Socket)
import Dict
import Json.Decode as JD exposing (Decoder, dict)


type JsVal
    = JsString String
    | JsInt Int
    | JsFloat Float
    | JsArray (List JsVal)
    | JsObject RegistryNode
    | JsNull


type alias RegistryNode =
    Dict.Dict String JsVal


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , debugMessages : List String
    , registryGlobal : JsVal
    }


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
