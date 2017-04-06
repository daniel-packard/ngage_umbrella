module Main exposing (..)

import Components.ListView as ListView
import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onCheck)
import Dict
import Http
import Json.Decode as Decode


eventDecoder =
    Decode.map6 Event
        (Decode.field "id" Decode.int)
        (Decode.field "inserted_at" Decode.string)
        (Decode.at [ "customer", "username" ] Decode.string)
        (Decode.at [ "event_definition", "description" ] Decode.string)
        (Decode.field "dismissed" Decode.bool)
        (Decode.field "contacted" Decode.bool)


eventsDecoder =
    Decode.field "events" (Decode.list eventDecoder)



-- MODEL


type alias Event =
    { id : Int
    , createdAt : String
    , username : String
    , eventDefinition : String
    , contacted : Bool
    , dismissed : Bool
    }


type alias Model =
    { loading : Bool
    , rand : Int
    , events : List Event
    }


eventDefinitions : Dict.Dict Int String
eventDefinitions =
    Dict.fromList
        [ ( 1, "User Registered" )
        , ( 2, "User Started Demo" )
        ]


initialEvents : List Event
initialEvents =
    []


initialModel : Model
initialModel =
    Model True 0 []



-- UPDATE


type Msg
    = Events (Result Http.Error String)
    | SetDismissed Int Bool
    | ToggleContacted Int
    | SetLoadingState Bool
    | NoOp


toggleEventContacted :
    List Event
    -> Int
    -> List Event
toggleEventContacted events id =
    let
        mark e =
            if e.id == id then
                { e | contacted = (not e.contacted) }
            else
                e
    in
        List.map mark events


setDismissEvent :
    List Event
    -> Int
    -> Bool
    -> List Event
setDismissEvent events id dismissed =
    let
        dismiss e =
            if e.id == id then
                { e | dismissed = dismissed }
            else
                e
    in
        List.map dismiss events


parseJsonEvents : String -> List Event
parseJsonEvents json =
    case Decode.decodeString eventsDecoder json of
        Ok value ->
            value

        Err err ->
            []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Events (Ok json) ->
            ( { model | events = (parseJsonEvents json), loading = False }, Cmd.none )

        Events (Err error) ->
            ( model, Cmd.none )

        SetLoadingState loadingState ->
            ( { model | loading = loadingState }, loadData )

        SetDismissed id dismissed ->
            ( { model | events = (setDismissEvent model.events id dismissed) }, Cmd.none )

        ToggleContacted id ->
            ( { model | events = (toggleEventContacted model.events id) }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


eventItemView : Event -> Html Msg
eventItemView n =
    div [ class "event list-group-item", classList [ ( "dismissed", n.dismissed ) ], hidden False ]
        [ span [ class "field" ] [ text (String.slice 0 16 n.createdAt) ]
        , span [ class "field" ] [ text n.username ]
        , span [ class "field" ] [ text n.eventDefinition ]
        , label [ class "field" ]
            [ text "contacted: "
            , input [ class "field", type_ "checkbox", onClick (ToggleContacted n.id), checked n.contacted ] []
            ]
        , button [ onClick (SetDismissed n.id True), hidden (n.dismissed) ] [ text "dismiss" ]
        , button [ class "restore-button", onClick (SetDismissed n.id False), hidden (not n.dismissed) ] [ text "restore" ]
        ]


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ span [ class "spinner", hidden (not model.loading) ] []
        , div [ class "event-feed-container", hidden model.loading ]
            [ h3 [] [ text ("Event Definitions " ++ (toString model.rand)) ]
            , ListView.view { items = Dict.toList eventDefinitions, template = Nothing }
            , h3 [] [ text "Event feed:" ]
            , ListView.view { items = model.events, template = Just eventItemView }
            , h4 [] [ text "DEBUG: raw event data" ]
            , ListView.view { items = model.events, template = Nothing }
            ]
        ]



-- COMMANDS


loadData : Cmd Msg
loadData =
    Cmd.none


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, getEvents )
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }


eventsUrl =
    "http://localhost:4000/api/v1/events"


getEvents : Cmd Msg
getEvents =
    eventsUrl
        |> Http.getString
        |> Http.send Events
