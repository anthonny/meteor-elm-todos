port module Main exposing (main)

import Browser
import Html exposing (Html, a, div, form, input, li, text, ul)
import Html.Attributes exposing (class, classList, href, placeholder, style, target, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)
import Svg
import Svg.Attributes as SvgAttr


type alias Model =
    { todo : String
    , todos : List Todo
    , filter : Filter
    }


type alias Todo =
    { id : String
    , value : String
    , status : TodoStatus
    }


type TodoStatus
    = Checked
    | Unchecked


type Filter
    = All
    | Active
    | Completed


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { todo = "", todos = [], filter = All }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "w-screen h-screen flex justify-center items-center bg-gray-500 text-gray-800" ]
        [ div
            [ class "flex flex-col h-full"
            , style "width" "400px"
            , style "max-height" "80%"
            ]
            [ div
                [ class "flex-1 flex flex-col bg-white shadow-xl overflow-hidden"
                ]
                [ form [ onSubmit AddTodo ]
                    [ input [ class "w-full px-4 py-4 shadow-sm", value model.todo, placeholder "Add a todo...", onInput InputChanged ] []
                    ]
                , div [ class "flex-1 overflow-scroll" ]
                    (List.map viewTodo (filterTodosBy model.filter model.todos))
                , viewFooter model
                ]
            , div [ class "mt-2 text-center text-sm text-gray-800" ]
                [ div []
                    [ text "Made with ❤️ by "
                    , link "https://twitter.com/anthonny_q" "@anthonny_q"
                    ]
                , div [ class "text-xs" ]
                    [ text "Propulsed by "
                    , link "https://elm-lang.org/" "Elm"
                    , text " and "
                    , link "https://www.meteor.com/" "Meteor"
                    ]
                ]
            ]
        ]


link : String -> String -> Html msg
link url label =
    a [ class "underline text-blue-600", href url, target "_blank" ] [ text label ]


viewTodo : Todo -> Html Msg
viewTodo todo =
    div [ class "flex items-center border-b-2 border-gray-100 px-4 py-4 fill-current" ]
        [ div [ class "text-gray-500 stroke-current cursor-pointer", onClick <| ToggleStatus todo.id ] [ statusIcon todo ]
        , div [ class "ml-4" ] [ text todo.value ]
        ]


filterTodosBy : Filter -> List Todo -> List Todo
filterTodosBy filter todos =
    List.filter (isFilteredTodo filter) todos


viewFooter : Model -> Html Msg
viewFooter model =
    div [ class "flex justify-between items-center px-4 py-2 bg-gray-800 text-white" ]
        [ div [] [ text <| activeItemsvalue model.todos ]
        , div []
            [ ul [ class "flex text-gray-600" ]
                [ li [ class "cursor-pointer", onClick (FilterBy All), classList [ ( "text-white", model.filter == All ) ] ] [ text "All" ]
                , li [ class "cursor-pointer ml-4", onClick (FilterBy Active), classList [ ( "text-white", model.filter == Active ) ] ] [ text "Active" ]
                , li [ class "cursor-pointer ml-4", onClick (FilterBy Completed), classList [ ( "text-white", model.filter == Completed ) ] ] [ text "Completed" ]
                ]
            ]
        ]


activeItemsvalue : List Todo -> String
activeItemsvalue todos =
    (String.fromInt <| List.length <| List.filter (\todo -> todo.status == Unchecked) todos) ++ " items left"


statusIcon : Todo -> Html msg
statusIcon todo =
    case todo.status of
        Checked ->
            checkedIcon

        Unchecked ->
            squareIcon


checkedIcon : Html msg
checkedIcon =
    Svg.svg [ SvgAttr.viewBox "0 0 512 512", SvgAttr.width "24", SvgAttr.height "24" ]
        [ Svg.path [ SvgAttr.fill "none", SvgAttr.strokeLinecap "round", SvgAttr.strokeLinejoin "round", SvgAttr.strokeWidth "32", SvgAttr.d "M352 176L217.6 336 160 272" ]
            []
        , Svg.rect [ SvgAttr.fill "none", SvgAttr.x "64", SvgAttr.y "64", SvgAttr.width "384", SvgAttr.height "384", SvgAttr.rx "48", SvgAttr.ry "48", SvgAttr.strokeLinejoin "round", SvgAttr.strokeWidth "32" ]
            []
        ]


squareIcon : Html msg
squareIcon =
    Svg.svg [ SvgAttr.viewBox "0 0 512 512", SvgAttr.width "24", SvgAttr.height "24" ]
        [ Svg.path [ SvgAttr.d "M416 448H96a32.09 32.09 0 01-32-32V96a32.09 32.09 0 0132-32h320a32.09 32.09 0 0132 32v320a32.09 32.09 0 01-32 32z", SvgAttr.fill "none", SvgAttr.strokeLinecap "round", SvgAttr.strokeLinejoin "round", SvgAttr.strokeWidth "32" ]
            []
        ]


type Msg
    = InputChanged String
    | AddTodo
    | ToggleStatus String
    | FilterBy Filter
    | ReceiveTodos (List Todo)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputChanged value ->
            ( { model | todo = value }, Cmd.none )

        AddTodo ->
            if String.isEmpty (String.trim model.todo) then
                ( model, Cmd.none )

            else
                ( { model | todo = "" }, addTodo model.todo )

        ToggleStatus todoId ->
            let
                updateTodo todo =
                    if todo.id == todoId then
                        { todo | status = toggleTodoStatus todo.status }

                    else
                        todo
            in
            ( model, toggleStatus todoId )

        FilterBy selectedFilter ->
            ( { model | filter = selectedFilter }, Cmd.none )

        ReceiveTodos todos ->
            ( { model | todos = todos }, Cmd.none )


isFilteredTodo : Filter -> Todo -> Bool
isFilteredTodo filter todo =
    case ( filter, todo.status ) of
        ( All, _ ) ->
            True

        ( Completed, Checked ) ->
            True

        ( Active, Unchecked ) ->
            True

        _ ->
            False


toggleTodoStatus : TodoStatus -> TodoStatus
toggleTodoStatus status =
    case status of
        Checked ->
            Unchecked

        Unchecked ->
            Checked


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveTodos
        (\value ->
            Decode.decodeValue decodeTodos value
                |> Result.withDefault []
                |> ReceiveTodos
        )


decodeTodo : Decode.Decoder Todo
decodeTodo =
    Decode.succeed Todo
        |> required "id" Decode.string
        |> required "value" Decode.string
        |> required "status" decodeStatus


decodeStatus : Decode.Decoder TodoStatus
decodeStatus =
    Decode.string
        |> Decode.andThen
            (\status ->
                case status of
                    "checked" ->
                        Decode.succeed Checked

                    _ ->
                        Decode.succeed Unchecked
            )


decodeTodos : Decode.Decoder (List Todo)
decodeTodos =
    Decode.list decodeTodo


port addTodo : String -> Cmd msg


port toggleStatus : String -> Cmd msg


port receiveTodos : (Decode.Value -> msg) -> Sub msg
