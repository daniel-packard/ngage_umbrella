module Main exposing (..)

import Date exposing (Date)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onCheck)
import Components.ListView as ListView


-- TYPES


type alias Event =
    { id : Int
    , createdAt : Date.Date
    , username : String
    , eventDefinitionId : Int
    , contacted : Bool
    , dismissed : Bool
    }


type alias EventDefinition =
    { username : String
    , description : String
    }



-- MODEL


type alias Model =
    { events : List Event }


initialModel : Model
initialModel =
    let
        date =
            Date.fromTime 0
    in
        Model
            [ Event 1 date "pack3754@gmail.com" 1 False False
            , Event 2 date "pack3754@gmail.com" 2 False False
            , Event 3 date "pack3754@gmail.com" 3 False False
            , Event 4 date "pack3754@gmail.com" 4 False False
            ]



-- UPDATE


type Msg
    = Dismiss Int
    | ToggleContacted Int
    | NoOp


toggleEventContacted events id =
    let
        mark e =
            if e.id == id then
                { e | contacted = (not e.contacted) }
            else
                e
    in
        List.map mark events


dismissEvent events id =
    let
        dismiss e =
            if e.id == id then
                { e | dismissed = True }
            else
                e
    in
        List.map dismiss events


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Dismiss id ->
            ( { model | events = (dismissEvent model.events id) }, Cmd.none )

        ToggleContacted id ->
            ( { model | events = (toggleEventContacted model.events id) }, Cmd.none )


eventDefinitions : Dict.Dict number String
eventDefinitions =
    Dict.fromList
        [ ( 1, "User Registered" )
        , ( 2, "User Started Demo" )
        ]


eventItemView : Event -> Html Msg
eventItemView n =
    let
        eventDescription =
            case Dict.get n.eventDefinitionId eventDefinitions of
                Nothing ->
                    "unknown event (id: " ++ (toString n.eventDefinitionId) ++ ")"

                Just value ->
                    value
    in
        div [ class "event list-group-item", hidden n.dismissed ]
            [ span [ class "field" ] [ text ("test" ++ (toString n.createdAt)) ]
            , span [ class "field" ] [ text n.username ]
            , span [ class "field" ] [ text eventDescription ]
            , label [ class "field" ]
                [ text "contacted: "
                , input [ class "field", type_ "checkbox" ] []
                ]
            , button [ onClick (Dismiss n.id) ] [ text "x" ]
            ]


view : Model -> Html Msg
view model =
    div [ class "event-feed-container" ]
        [ h3 [] [ text "Event feed:" ]
        , ListView.view { items = model.events, template = Just eventItemView }
        , h3 [] [ text "Event Definitions" ]
        , ListView.view { items = Dict.toList eventDefinitions, template = Nothing }
        , h4 [] [ text "DEBUG: raw event data" ]
        , ListView.view { items = model.events, template = Nothing }
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }
