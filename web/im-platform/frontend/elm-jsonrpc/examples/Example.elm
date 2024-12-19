module Example exposing (main)

{-| -}

import Api
import Browser
import Html exposing (Html)
import Html.Events exposing (onClick)
import Http
import Jsonrpc exposing (RpcData, RpcError, call, toResult)
import W.Button
import W.Container
import W.InputCheckbox
import W.InputField
import W.InputText
import W.Modal
import W.Text



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



-- MODEL


type alias Model =
    { token : Maybe Api.Token
    , err : Maybe RpcError
    , username : String
    , password : String
    , guildname : String
    }


initModel =
    Model Nothing Nothing "user" "password" ""


init : () -> ( Model, Cmd Msg )
init _ =
    ( initModel, Cmd.none )



-- UPDATE


type Msg
    = UpdateModel Model
    | ClickSignIn
    | GotToken (RpcData Api.Token)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateModel m ->
            ( m, Cmd.none )

        ClickSignIn ->
            ( model
            , Api.signin
                { params = { username = model.username, password = model.password }
                , url = Api.url
                , handler = GotToken
                , token = Nothing
                }
            )

        GotToken data ->
            case data |> toResult of
                Err err ->
                    ( { model | err = Just err, token = Nothing }, Cmd.none )

                Ok token ->
                    ( { model | token = Just token, err = Nothing }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    form model


form : Model -> Html Msg
form model =
    [ W.Text.view
        [ W.Text.extraLarge, W.Text.aux ]
        [ Html.text "欢迎" ]
    , W.InputField.view []
        { label = [ Html.text "账号" ]
        , input =
            [ W.InputText.view []
                { value = model.username
                , onInput = \new -> UpdateModel { model | username = new }
                }
            ]
        }
    , W.InputField.view []
        { label = [ Html.text "密码" ]
        , input =
            [ W.InputText.view [ W.InputText.password ]
                { value = model.password
                , onInput = \new -> UpdateModel { model | password = new }
                }
            ]
        }

    --, W.Text.view [W.Text.color "red"] [ Html.text model.err ]
    , W.Button.view []
        { label = [ Html.text "登录" ]
        , onClick = ClickSignIn
        }
    ]
        |> W.Container.view
            [ W.Container.padX_16
            , W.Container.padY_4
            , W.Container.alignCenterX
            , W.Container.card
            ]
        |> List.singleton
        |> W.Container.view
            [ W.Container.alignCenterX
            , W.Container.alignCenterY
            , W.Container.styleAttrs [ ( "height", "100%" ) ]
            ]
