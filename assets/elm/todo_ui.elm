import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as JD
import Json.Decode.Pipeline as JDP exposing (decode, required, optional)

type alias TodoTask = {
    todoName: String
    , complete: Bool
}

type alias Model = {
    todoList: List TodoTask
}

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

type Msg = NoOp | OnHttpResponse (Result Http.Error (List TodoTask))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OnHttpResponse (Ok list) -> 
            ({model | todoList = list}, Cmd.none)
        
        OnHttpResponse (Err _) -> 
            (model, Cmd.none)

view : Model -> Html Msg
view model =
    model.todoList
        |> List.map generateCard
        |> div[]
    
generateCard: TodoTask -> Html Msg
generateCard task = 
    div[class "container"][
        div[class "row"][
            div[class "col-sm-12 display-2"][
                if(task.complete) then
                    i[class "fa fa-times text-danger"][]
                else
                    i[class "fa fa-check text-success"][]
                , text task.todoName
                , div[class "pull-right"][
                    i[class "far fa-trash-alt text-danger"][]
                ]
            ]
        ]
    ]

fetchInitialTodo: Cmd Msg
fetchInitialTodo = 
    let
        url = "http://localhost:4000/api/todos"
    in
        Http.send OnHttpResponse (Http.get url extractList)

extractList = JD.list extractDetails

extractDetails: JD.Decoder TodoTask
extractDetails = 
    decode TodoTask
    |> JDP.required "task_name" JD.string
    |> JDP.required "complete" JD.bool

init: (Model, Cmd Msg)
init = (Model [], fetchInitialTodo)

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }