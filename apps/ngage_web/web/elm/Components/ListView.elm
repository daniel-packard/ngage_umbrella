module Components.ListView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


type alias ItemTemplate a msg =
    a -> Html msg


type alias Model a msg =
    { items : List a
    , template : Maybe (a -> Html msg)
    }


view : Model a msg -> Html msg
view model =
    let
        itemViews =
            case model.template of
                Maybe.Nothing ->
                    List.map (\x -> div [] [ toString x |> text ]) model.items

                Maybe.Just itemTemplate ->
                    List.map (\i -> itemTemplate i) model.items
    in
        div [ class "list-group" ] itemViews
