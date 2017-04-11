module Components.ListView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


type alias ItemTemplate a msg =
    a -> Html msg


type alias Model a msg =
    { items : List a
    , filter : a -> Bool
    , template : Maybe (a -> Html msg)
    }


view : Model a msg -> Html msg
view model =
    let
        items =
            List.filter model.filter model.items

        itemViews =
            case model.template of
                Maybe.Nothing ->
                    List.map (\x -> div [] [ toString x |> text ]) items

                Maybe.Just itemTemplate ->
                    List.map (\i -> itemTemplate i ) items
    in
        div [ class "list-group" ] itemViews
