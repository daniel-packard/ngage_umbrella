module Main exposing (..)

import Components.ListView as ListView
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onCheck)
import Dict
import Http
import Json.Decode as Decode
import Json.Encode as Encode


eventDecoder : Decode.Decoder Event
eventDecoder =
    Decode.map6 Event
        (Decode.field "id" Decode.int)
        (Decode.field "inserted_at" Decode.string)
        (Decode.at [ "customer", "username" ] Decode.string)
        (Decode.at [ "event_definition", "description" ] Decode.string)
        (Decode.field "contacted" Decode.bool)
        (Decode.field "dismissed" Decode.bool)


eventsDecoder : Decode.Decoder (List Event)
eventsDecoder =
    Decode.field "events" (Decode.list eventDecoder)


encodeEvent : Event -> Encode.Value
encodeEvent event =
    Encode.object
        [ ( "id", Encode.int event.id )
        , ( "dismissed", Encode.bool event.dismissed )
        , ( "contacted", Encode.bool event.contacted )
        ]



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
    , filterDismissedItems : Bool
    , searchTerm : String
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
    Model True True "" []



-- UPDATE


type Msg
    = Events (Result Http.Error String)
    | SetDismissed Int Bool
    | ToggleContacted Int
    | ToggleDismissedItemsFilter
    | SetLoadingState Bool
    | UpdateEvent (Result Http.Error Event)
    | Search String
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
            let
                updatedEvents =
                    parseJsonEvents json |> List.sortBy .id
            in
                ( { model | events = updatedEvents, loading = False }, Cmd.none )

        Events (Err error) ->
            ( model, Cmd.none )

        SetLoadingState loadingState ->
            ( { model | loading = loadingState }, loadData )

        SetDismissed id dismissed ->
            let
                updatedEvents =
                    setDismissEvent model.events id dismissed
            in
                ( { model | events = updatedEvents }, updateEvent updatedEvents id )

        ToggleContacted id ->
            let
                updatedEvents =
                    toggleEventContacted model.events id
            in
                ( { model | events = updatedEvents }, updateEvent updatedEvents id )

        ToggleDismissedItemsFilter ->
            ( { model | filterDismissedItems = not model.filterDismissedItems }, Cmd.none )

        UpdateEvent result ->
            ( model, Cmd.none )

        Search searchTerm ->
            ( { model | searchTerm = searchTerm }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


eventItemView : Event -> Html Msg
eventItemView n =
    div
        [ class "event list-group-item", classList [ ( "dismissed", n.dismissed ) ] ]
        [ span [ class "row-label" ] [ text (toString n.id) ]
        , span [ class "field" ] [ text (String.slice 0 16 n.createdAt) ]
        , span [ class "field" ] [ text n.username ]
        , span [ class "field" ] [ text n.eventDefinition ]
        , label [ class "field" ]
            [ text "contacted: "
            , input [ class "field", type_ "checkbox", onClick (ToggleContacted n.id), checked n.contacted ] []
            ]
        , button [ onClick (SetDismissed n.id True), hidden (n.dismissed) ] [ text "dismiss" ]
        , button [ onClick (SetDismissed n.id False), hidden (not n.dismissed) ] [ text "restore" ]
        ]


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


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ span [ class "spinner", hidden (not model.loading) ] []
        , div [ class "event-feed-container", hidden model.loading ]
            [ h3 [] [ text "Event Definitions: " ]
            , ListView.view { items = Dict.toList eventDefinitions, template = Nothing }
            , eventFeedHeader model
            , div [ class "event-feed" ]
                [ ListView.view
                    { items =
                        model.events
                            |> List.filter (\e -> String.contains model.searchTerm e.username)
                            |> List.filter (\e -> ((not e.dismissed) || (not model.filterDismissedItems)))
                    , template = Just (eventItemView)
                    }
                ]
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


getEvents : Cmd Msg
getEvents =
    eventsUrl
        |> Http.getString
        |> Http.send Events


updateEvent : List Event -> Int -> Cmd Msg
updateEvent events id =
    let
        event =
            case (events |> List.filter (\e -> e.id == id) |> List.head) of
                Just e ->
                    e

                Nothing ->
                    Event 0 "" "" "" False False

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
