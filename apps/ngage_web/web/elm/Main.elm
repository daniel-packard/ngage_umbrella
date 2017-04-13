module Main exposing (..)

import Components.ListView as ListView
import Date exposing (..)
import Date.Format exposing (format)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onCheck)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


-- ENCODERS/DECODERS


stringToDate : Decode.Decoder Date.Date
stringToDate =
    Decode.string
        |> Decode.andThen
            (\val ->
                case Date.fromString val of
                    Err err ->
                        Decode.fail err

                    Ok result ->
                        Decode.succeed result
            )


eventDefinitionDecoder : Decode.Decoder EventDefinition
eventDefinitionDecoder =
    Decode.map2 EventDefinition
        (Decode.field "id" Decode.int)
        (Decode.field "description" Decode.string)


eventDecoder : Decode.Decoder Event
eventDecoder =
    Decode.map6 Event
        (Decode.field "id" Decode.int)
        (Decode.field "inserted_at" stringToDate)
        (Decode.at [ "customer", "username" ] Decode.string)
        (Decode.at [ "event_definition", "description" ] Decode.string)
        (Decode.field "contacted" Decode.bool)
        (Decode.field "dismissed" Decode.bool)


eventsDecoder : Decode.Decoder (List Event)
eventsDecoder =
    Decode.field "events" (Decode.list eventDecoder)


eventDefinitionsDecoder : Decode.Decoder (List EventDefinition)
eventDefinitionsDecoder =
    Decode.field "eventDefinitions" (Decode.list eventDefinitionDecoder)


encodeEvent : Event -> Encode.Value
encodeEvent event =
    Encode.object
        [ ( "id", Encode.int event.id )
        , ( "dismissed", Encode.bool event.dismissed )
        , ( "contacted", Encode.bool event.contacted )
        ]


parseJsonEventDefinitions : String -> List EventDefinition
parseJsonEventDefinitions json =
    case Decode.decodeString eventDefinitionsDecoder json of
        Ok value ->
            value

        Err err ->
            []


parseJsonEvents : String -> List Event
parseJsonEvents json =
    case Decode.decodeString eventsDecoder json of
        Ok value ->
            value

        Err err ->
            []



-- TYPE ALIASES


type alias Event =
    { id : Int
    , createdAt : Date
    , username : String
    , eventDefinition : String
    , contacted : Bool
    , dismissed : Bool
    }


type alias EventDefinition =
    { id : Int
    , description : String
    }



-- MODEL


type alias Model =
    { loading : Bool
    , filterDismissedItems : Bool
    , searchTerm : String
    , events : List Event
    , eventDefinitions : List EventDefinition
    }


initialModel : Model
initialModel =
    Model True True "" [] []



-- UPDATE


type Msg
    = EventDefinitions (Result Http.Error String)
    | Events (Result Http.Error String)
    | SetDismissed Int Bool
    | ToggleContacted Int
    | ToggleDismissedItemsFilter
    | SetLoadingState Bool
    | UpdateEvent (Result Http.Error Event)
    | Search String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EventDefinitions (Ok json) ->
            let
                updatedEventDefinitions =
                    parseJsonEventDefinitions json |> List.sortBy .id

                _ =
                    Debug.log "success"
            in
                ( { model | eventDefinitions = updatedEventDefinitions }, Cmd.none )

        EventDefinitions (Err error) ->
            ( model, Cmd.none )

        Events (Ok json) ->
            let
                updatedEvents =
                    parseJsonEvents json |> List.sortBy .id |> List.reverse
            in
                ( { model | events = updatedEvents, loading = False }, getEventDefinitions )

        Events (Err error) ->
            ( model, Cmd.none )

        SetLoadingState loadingState ->
            ( { model | loading = loadingState }, loadData )

        SetDismissed id dismissed ->
            let
                updatedEvents =
                    setDismissEvent model.events id dismissed
            in
                ( { model | events = updatedEvents }, patchEventUpdate updatedEvents id )

        ToggleContacted id ->
            let
                updatedEvents =
                    toggleEventContacted model.events id
            in
                ( { model | events = updatedEvents }, patchEventUpdate updatedEvents id )

        ToggleDismissedItemsFilter ->
            ( { model | filterDismissedItems = not model.filterDismissedItems }, Cmd.none )

        UpdateEvent result ->
            ( model, Cmd.none )

        Search searchTerm ->
            ( { model | searchTerm = searchTerm }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


toggleEventContacted : List Event -> Int -> List Event
toggleEventContacted events id =
    let
        mark e =
            if e.id == id then
                { e | contacted = (not e.contacted) }
            else
                e
    in
        List.map mark events


setDismissEvent : List Event -> Int -> Bool -> List Event
setDismissEvent events id dismissed =
    let
        dismiss e =
            if e.id == id then
                { e | dismissed = dismissed }
            else
                e
    in
        List.map dismiss events



-- VIEWS


eventFeedHeader : Model -> Html Msg
eventFeedHeader model =
    div [ class "event-feed-header" ]
        [ h3 [ class "event-feed-header-item" ] [ text "Event feed: " ]
        , input [ class "event-feed-header-item", placeholder "search by username", onInput Search ] []
        , small [ style [ ( "margin-left", "10px" ) ] ]
            [ label
                []
                [ text "Hide dismissed items: "
                , input [ class "field", type_ "checkbox", onClick (ToggleDismissedItemsFilter), checked model.filterDismissedItems ] []
                ]
            ]
        ]


eventItemViewTemplate : Event -> Html Msg
eventItemViewTemplate n =
    div
        [ class "event list-group-item", classList [ ( "dismissed", n.dismissed ) ] ]
        [ span [ class "row-label" ] [ text (toString n.id) ]
        , span [ class "field" ] [ text (Date.Format.format "%y/%m/%d %I:%M" n.createdAt) ]
        , span [ class "field" ] [ text n.username ]
        , span [ class "field" ] [ text n.eventDefinition ]
        , label [ class "field" ]
            [ text "contacted: "
            , input [ class "field", type_ "checkbox", onClick (ToggleContacted n.id), checked n.contacted ] []
            ]
        , button [ onClick (SetDismissed n.id True), hidden (n.dismissed) ] [ text "dismiss" ]
        , button [ onClick (SetDismissed n.id False), hidden (not n.dismissed) ] [ text "restore" ]
        ]


eventsFilter : Model -> List Event -> List Event
eventsFilter model events =
    events
        |> List.filter (\e -> String.contains model.searchTerm e.username)
        |> List.filter (\e -> ((not e.dismissed) || (not model.filterDismissedItems)))


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ span [ class "spinner", hidden (not model.loading) ] []
        , div [ class "event-feed-container", hidden model.loading ]
            [ eventFeedHeader model
            , div [ class "event-feed" ]
                [ ListView.view { items = model.events |> eventsFilter model, template = Just eventItemViewTemplate } ]
            , h3 [] [ text "Event Definitions: " ]
            , ListView.view { items = model.eventDefinitions, template = Nothing }
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


eventsUrl : String
eventsUrl =
    "http://localhost:4000/api/v1/events"


eventDefnitionsUrl : String
eventDefnitionsUrl =
    "http://localhost:4000/api/v1/event_definitions"


getEvents : Cmd Msg
getEvents =
    eventsUrl
        |> Http.getString
        |> Http.send Events


getEventDefinitions : Cmd Msg
getEventDefinitions =
    eventDefnitionsUrl
        |> Http.getString
        |> Http.send EventDefinitions


patchEventUpdate : List Event -> Int -> Cmd Msg
patchEventUpdate events id =
    let
        event =
            case (events |> List.filter (\e -> e.id == id) |> List.head) of
                Just e ->
                    e

                Nothing ->
                    Event 0 (Date.fromTime 0) "" "" False False

        url =
            "http://localhost:4000/api/v1/events/" ++ (toString id)

        body =
            encodeEvent event
                |> Http.jsonBody

        request =
            Http.request
                { method = "PATCH"
                , headers = []
                , url = url
                , body = body
                , expect = Http.expectJson eventDecoder
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send UpdateEvent request
