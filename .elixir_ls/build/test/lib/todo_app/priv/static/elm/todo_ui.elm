module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as JD
import Json.Decode.Pipeline as JDP exposing (decode, required, optional)


type alias TodoTask =
    { todoName : String
    , complete : Bool
    }


type alias Model =
    { todoList : List TodoTask
    , newItem : String
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Msg
    = NoOp
    | OnHttpResponse (Result Http.Error (List TodoTask))
    | Add
    | UpdateValue String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OnHttpResponse (Ok list) ->
            ( { model | todoList = list }, Cmd.none )

        OnHttpResponse (Err _) ->
            ( model, Cmd.none )
        
        UpdateValue value ->
            ({model | newItem = value}, Cmd.none)

        Add ->
            (model, Cmd.none)

onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                JD.succeed msg
            else
                JD.fail "not ENTER"
    in
        on "keydown" (JD.andThen isEnter keyCode)


view : Model -> Html Msg
view model =
    div [class "container"]
        [ input [ type_ "text", placeholder "Enter Todo Item", class "form-control input-lg", onEnter Add, onInput UpdateValue ] []
        , model.todoList
            |> List.map generateCard
            |> div []
        ]


generateCard : TodoTask -> Html Msg
generateCard task =
    div [ class "row shadow", style [ ( "margin", "10px 0px" ), ( "padding", "10px" ) ] ]
        [ div [ class "col-sm-12 display-3" ]
            [ if (task.complete) then
                i [ class "fa fa-times text-danger" ] []
              else
                i [ class "fa fa-check text-success" ] []
            , text "  "
            , text task.todoName
            , div [ class "pull-right" ]
                [ i [ class "far fa-trash-alt text-danger" ] []
                ]
            ]
        ]


fetchInitialTodo : Cmd Msg
fetchInitialTodo =
    let
        url =
            "http://localhost:4000/api/todos"
    in
        Http.send OnHttpResponse (Http.get url extractList)


extractList =
    JD.list extractDetails


extractDetails : JD.Decoder TodoTask
extractDetails =
    decode TodoTask
        |> JDP.required "task_name" JD.string
        |> JDP.required "complete" JD.bool


init : ( Model, Cmd Msg )
init =
    ( Model [] "", fetchInitialTodo )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
