module Nerves.SystemConfig.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Dict exposing (toList)
import Nerves.SystemConfig.Model exposing (Model, JsVal(..), RegistryNode)
import Nerves.SystemConfig.Messages exposing (Msg(..))
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.ListGroup as ListGroup


view : Model -> Html Msg
view model =
    let
        cwd =
            List.reverse model.cwd

        branch =
            getBranch cwd model.registryGlobal
    in
        div [ class "navigation" ]
            [ CDN.stylesheet
            , Grid.container []
                [ ListGroup.ul
                    (renderBranch branch model.cwd)
                ]
            ]


getBranch : List String -> RegistryNode -> RegistryNode
getBranch cwd branch =
    case cwd of
        [] ->
            branch

        h :: t ->
            case (Dict.get h branch) of
                Nothing ->
                    branch

                Just (JsObject val) ->
                    getBranch t val

                _ ->
                    branch


renderNode : List String -> String -> JsVal -> ListGroup.Item Msg
renderNode cwd key value =
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
                [ a [ href "#", onClick (Navigate (key :: cwd)) ] [ text key ]
                ]

        JsNull ->
            ListGroup.li []
                [ text "nil" ]


renderBranch : RegistryNode -> List String -> List (ListGroup.Item Msg)
renderBranch branch cwd =
    Dict.toList branch
        |> List.map
            (\( k, v ) ->
                (renderNode cwd k v)
            )
