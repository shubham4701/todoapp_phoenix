module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Encode as JE
import Json.Decode as JD
import Json.Decode.Pipeline as JDP exposing (decode, required, optional)


type alias TodoTask =
    { id : Int
    , todoName : String
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
    | ToggleStatus Int
    | DeleteStatus Int
    | CheckEnter Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OnHttpResponse (Ok list) ->
            ( { model | todoList = list, newItem = "" }, Cmd.none )

        OnHttpResponse (Err _) ->
            ( model, Cmd.none )

        UpdateValue value ->
            ( { model | newItem = value }, Cmd.none )

        Add ->
            ( model, Cmd.none )

        ToggleStatus id ->
            ( model, toggleStatus id )

        DeleteStatus id ->
            ( model, deleteTodo id )

        CheckEnter keyCode ->
            if (keyCode == 13) then
                ( model, postnewTodo model )
            else
                ( model, Cmd.none )


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (JD.map tagger keyCode)


convertToJson : String -> Http.Body
convertToJson value =
    JE.object [ ( "task_name", JE.string value ) ]
        |> Http.jsonBody


postnewTodo : Model -> Cmd Msg
postnewTodo model =
    Http.send OnHttpResponse (Http.post "/api/todos/create" (convertToJson model.newItem) extractList)


fetchInitialTodo : Cmd Msg
fetchInitialTodo =
    let
        url =
            "/api/todos"
    in
        Http.send OnHttpResponse (Http.get url extractList)


toggleStatus : Int -> Cmd Msg
toggleStatus id =
    let
        url =
            "/api/todos/toggle/" ++ toString (id)
    in
        Http.send OnHttpResponse (Http.get url extractList)


deleteTodo : Int -> Cmd Msg
deleteTodo id =
    let
        url =
            "/api/todos/delete/" ++ toString (id)
    in
        Http.send OnHttpResponse (Http.get url extractList)


extractList =
    JD.list extractDetails


extractDetails : JD.Decoder TodoTask
extractDetails =
    decode TodoTask
        |> JDP.required "id" JD.int
        |> JDP.required "task_name" JD.string
        |> JDP.required "complete" JD.bool


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ input
            [ type_ "text"
            , placeholder "Enter Todo Item"
            , class "form-control input-lg"
            , onKeyDown CheckEnter
            , onInput UpdateValue
            , value model.newItem
            ]
            []
        , model.todoList
            |> List.map generateCard
            |> div []
        ]


generateCard : TodoTask -> Html Msg
generateCard task =
    div [ class "row shadow", style [ ( "margin", "10px 0px" ), ( "padding", "10px" ) ] ]
        [ div [ class "col-sm-12 display-3" ]
            [ if (task.complete) then
                div []
                    [ i [ class "fa fa-times text-danger", onClick (ToggleStatus task.id) ] []
                    , text "  "
                    , span [ class "text-muted", style [ ( "text-decoration", "line-through" ) ] ]
                        [ text task.todoName ]
                    , div
                        [ class "pull-right" ]
                        [ i [ class "far fa-trash-alt text-danger", onClick (DeleteStatus task.id) ] []
                        ]
                    ]
              else
                div []
                    [ i [ class "fa fa-check text-success", onClick (ToggleStatus task.id) ] []
                    , text "  "
                    , text task.todoName
                    , div [ class "pull-right" ]
                        [ i [ class "far fa-trash-alt text-danger", onClick (DeleteStatus task.id) ] []
                        ]
                    ]
            ]
        ]


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
