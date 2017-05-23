module Nerves.SystemConfig.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Nerves.SystemConfig.Model exposing (Model)
import Nerves.SystemConfig.Messages exposing (Msg(..))
import Bootstrap.CDN as CDN


view : Model -> Html Msg
view model =
    div [ class "navigation" ]
        [ CDN.stylesheet
        ]
