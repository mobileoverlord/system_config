module Nerves.SystemConfig.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Dict exposing (toList)
import Nerves.SystemConfig.Model exposing (Model, JsVal(..))
import Nerves.SystemConfig.Messages exposing (Msg(..))
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.ListGroup as ListGroup


view : Model -> Html Msg
view model =
    div [ class "navigation" ]
        [ CDN.stylesheet
        , Grid.container []
            [ ListGroup.ul
                (renderBranch model.registryGlobal)
            ]
        ]


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
                [ a [ href key ] [ text key ]
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
