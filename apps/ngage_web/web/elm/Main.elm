module Main exposing (..)

import Components.ListView as ListView
import Date exposing (Date)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onCheck)


-- MODEL


type alias Event =
    { id : Int
    , createdAt : Date.Date
    , username : String
    , eventDefinitionId : Int
    , contacted : Bool
    , dismissed : Bool
    }


type alias Model =
    { loading : Bool
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
    [ Event 1 (Date.fromTime 1) "pack3754@gmail.com" 1 False False
    , Event 2 (Date.fromTime 1) "pack3754@gmail.com" 2 True True
    , Event 3 (Date.fromTime 1) "pack3754@gmail.com" 3 False False
    , Event 4 (Date.fromTime 1) "pack3754@gmail.com" 4 False False
    ]


initialModel : Model
initialModel =
    Model True initialEvents



-- UPDATE


type Msg
    = SetDismissed Int Bool
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetLoadingState loadingState ->
            ( { model | loading = loadingState }, Cmd.none )

        SetDismissed id dismissed ->
            ( { model | events = (setDismissEvent model.events id dismissed) }, Cmd.none )

        ToggleContacted id ->
            ( { model | events = (toggleEventContacted model.events id) }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


getEventDescription : Int -> String
getEventDescription eventDefinitionId =
    case Dict.get eventDefinitionId eventDefinitions of
        Just value ->
            value

        Nothing ->
            "unknown event (id: " ++ (toString eventDefinitionId) ++ ")"


eventItemView : Event -> Html Msg
eventItemView n =
    let
        eventDescription =
            getEventDescription n.eventDefinitionId
    in
        div [ class "event list-group-item", classList [ ( "dismissed", n.dismissed ) ], hidden False ]
            [ span [ class "field" ] [ text (toString n.createdAt) ]
            , span [ class "field" ] [ text n.username ]
            , span [ class "field" ] [ text eventDescription ]
            , label [ class "field" ]
                [ text "contacted: "
                , input [ class "field", type_ "checkbox", onClick (ToggleContacted n.id), checked n.contacted ] []
                ]
            , button [ onClick (SetDismissed n.id True), hidden (n.dismissed) ] [ text "x" ]
            , button [ class "restore-button", onClick (SetDismissed n.id False), hidden (not n.dismissed) ] [ text "restore" ]
            ]


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ button [ onClick (SetLoadingState (not model.loading)) ] [ text "toggle loading" ]
        , span [ class "spinner", hidden (not model.loading) ] []
        , div [ class "event-feed-container", hidden model.loading ]
            [ h3 [] [ text "Event Definitions" ]
            , ListView.view { items = Dict.toList eventDefinitions, template = Nothing }
            , h3 [] [ text "Event feed:" ]
            , ListView.view { items = model.events, template = Just eventItemView }
            , h4 [] [ text "DEBUG: raw event data" ]
            , ListView.view { items = model.events, template = Nothing }
            ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }
