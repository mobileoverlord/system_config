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
import Bootstrap.Navbar as Navbar
import Bootstrap.Form.InputGroup as InputGroup
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button


view : Model -> Html Msg
view model =
    let
        rev =
            List.reverse model.cwd

        branch =
            getBranch rev model.registryGlobal

        editable =
            case rev of
                "config" :: _ ->
                    True

                _ ->
                    False
    in
        div [ class "navigation" ]
            [ CDN.stylesheet
            , Navbar.config NavbarMsg
                |> Navbar.withAnimation
                |> Navbar.brand [ onClick (Navigate []) ] [ text "SystemConfig" ]
                |> Navbar.items
                    (renderBreadcrumb model.cwd [])
                |> Navbar.view model.navbarState
            , Grid.container []
                [ renderBranch editable branch model.cwd
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


renderNode : Bool -> List String -> String -> JsVal -> ListGroup.Item Msg
renderNode editable cwd key value =
    case value of
        JsString value ->
            renderLeaf editable key value

        JsInt value ->
            renderLeaf editable key (toString value)

        JsFloat value ->
            renderLeaf editable key (toString value)

        JsArray value ->
            renderLeaf editable key (renderList value)

        JsObject obj ->
            ListGroup.li []
                [ a [ href "#", onClick (Navigate (key :: cwd)) ] [ text key ]
                ]

        JsNull ->
            ListGroup.li []
                [ text "nil" ]


renderList : List JsVal -> String
renderList list =
    list
        |> List.map
            (\item ->
                case item of
                    JsString value ->
                        value

                    JsInt value ->
                        toString value

                    JsFloat value ->
                        toString value

                    JsArray value ->
                        renderList value

                    JsObject obj ->
                        "%{...}"

                    JsNull ->
                        "nil"
            )
        |> List.intersperse ", "
        |> List.foldr (++) ""


renderLeaf : Bool -> String -> String -> ListGroup.Item Msg
renderLeaf editable key value =
    ListGroup.li []
        [ InputGroup.config
            (InputGroup.text [ Input.disabled (not editable), Input.defaultValue value, Input.onInput (\v -> CacheValue key v) ])
            |> InputGroup.small
            |> InputGroup.predecessors
                [ InputGroup.span [] [ text key ] ]
            |> renderSuccessors editable key
            |> InputGroup.view
        ]


renderSuccessors : Bool -> String -> InputGroup.Config Msg -> InputGroup.Config Msg
renderSuccessors editable key inputGroup =
    case editable of
        True ->
            inputGroup
                |> InputGroup.successors
                    [ InputGroup.button [ Button.disabled (not editable), Button.success, Button.onClick (SaveValue key) ] [ text "✓" ] ]

        False ->
            inputGroup


renderBranch : Bool -> RegistryNode -> List String -> Html Msg
renderBranch editable branch cwd =
    ListGroup.ul
        (Dict.toList
            branch
            |> List.map
                (\( k, v ) ->
                    (renderNode editable cwd k v)
                )
        )


renderBreadcrumb : List String -> List (Navbar.Item Msg) -> List (Navbar.Item Msg)
renderBreadcrumb cwd items =
    case cwd of
        [] ->
            items

        h :: t ->
            (Navbar.itemLink [ onClick (Navigate (h :: t)) ] [ text h ] :: items)
                |> renderBreadcrumb t
