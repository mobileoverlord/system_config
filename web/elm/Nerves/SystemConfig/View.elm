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


view : Model -> Html Msg
view model =
    let
        branch =
            getBranch (List.reverse model.cwd) model.registryGlobal
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
            renderLeaf key value

        JsInt value ->
            renderLeaf key (toString value)

        JsFloat value ->
            renderLeaf key (toString value)

        JsArray value ->
            renderLeaf key (renderList value)

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


renderLeaf : String -> String -> ListGroup.Item Msg
renderLeaf key value =
    ListGroup.li []
        [ span [] [ text (key ++ ":") ]
        , span [] [ text (toString value) ]
        ]


renderBranch : RegistryNode -> List String -> List (ListGroup.Item Msg)
renderBranch branch cwd =
    Dict.toList branch
        |> List.map
            (\( k, v ) ->
                (renderNode cwd k v)
            )


renderBreadcrumb : List String -> List (Navbar.Item Msg) -> List (Navbar.Item Msg)
renderBreadcrumb cwd items =
    case cwd of
        [] ->
            items

        h :: t ->
            (Navbar.itemLink [ onClick (Navigate (h :: t)) ] [ text h ] :: items)
                |> renderBreadcrumb t
