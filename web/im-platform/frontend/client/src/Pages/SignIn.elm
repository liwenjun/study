module Pages.SignIn exposing (Model, Msg, page)

{-|

@docs Model, Msg, page

-}

import ChatApi exposing (Token, User)
import ChatApi.Users
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes exposing (attribute)
import Jsonrpc exposing (RpcData, toResult)
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Utils
import View exposing (View)
import W.Button
import W.Container
import W.InputCheckbox
import W.InputField
import W.InputText
import W.Modal
import W.Text


{-| -}
page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init shared
        , update = update shared
        , subscriptions = subscriptions
        , view = view
        }


{-| -}
usernameHtmlId : String
usernameHtmlId =
    "signin-username-input"



-- INIT


{-| -}
type alias Model =
    { username : String
    , password : String
    , rePassword : String
    , errorMessage : String
    , rememberMe : Bool
    , canRegister : Bool
    , isSamePassword : Bool
    }


{-| -}
init : Shared.Model -> () -> ( Model, Effect Msg )
init shared () =
    ( { username = "user"
      , password = "password"
      , rePassword = ""
      , errorMessage = ""
      , rememberMe = False
      , canRegister = False
      , isSamePassword = False
      }
    , if shared.wsConnected then
        Effect.batch
            [ Effect.closeWebsocketServer
            , Utils.setFocus usernameHtmlId SetInputFocused
            ]

      else
        Utils.setFocus usernameHtmlId SetInputFocused
    )



-- UPDATE


{-| -}
type Msg
    = UpdateModel Model
    | ClickSignIn (Maybe User)
    | OnSignIn (Maybe User) (RpcData Token)
    | OnGetSelf Token (RpcData User)
    | OnCheckUser (RpcData Bool)
    | OnCreateUser (RpcData User)
    | SetRememberMe Bool
      ---
    | OnFinishVerifyPassword Bool
      ---
    | SetInputFocused


{-| -}
update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        SetInputFocused ->
            ( model, Effect.none )

        UpdateModel m ->
            ( { m | isSamePassword = m.password == m.rePassword && String.length m.password > 0 }, Effect.none )

        ClickSignIn data ->
            ( model
            , ChatApi.Users.login
                { url = shared.baseUrl
                , params = { username = model.username, password = model.password }
                , handler = OnSignIn data
                }
                |> Effect.sendCmd
            )

        OnSignIn aUser data ->
            case data |> toResult of
                Ok token ->
                    ( model
                    , case aUser of
                        Just u ->
                            Effect.signIn { user = u, token = token }

                        Nothing ->
                            ChatApi.Users.getSelf
                                { url = shared.baseUrl
                                , token = token.token |> Just
                                , handler = OnGetSelf token
                                }
                                |> Effect.sendCmd
                    )

                Err e ->
                    ( { model | errorMessage = "Err" }
                    , ChatApi.Users.check
                        { url = shared.baseUrl
                        , params = model.username
                        , handler = OnCheckUser
                        }
                        |> Effect.sendCmd
                    )

        OnGetSelf token data ->
            case data |> toResult of
                Ok u ->
                    ( model
                    , Effect.signIn { user = u, token = token }
                    )

                _ ->
                    ( model, Effect.none )

        OnCheckUser data ->
            case data |> toResult of
                Ok True ->
                    ( { model | errorMessage = "账号或密码错误！" }, Effect.none )

                Ok False ->
                    ( { model | errorMessage = "", canRegister = True }
                    , Effect.none
                    )

                Err _ ->
                    ( model, Effect.none )

        OnCreateUser data ->
            case data |> toResult of
                Ok u ->
                    ( { model | errorMessage = "" }, Effect.sendMsg (ClickSignIn <| Just u) )

                Err e ->
                    ( { model | errorMessage = "Err" }
                      -- Api.toUserFriendlyMessage httpError }
                    , Effect.none
                    )

        SetRememberMe bool ->
            ( { model | rememberMe = bool }, Effect.none )

        OnFinishVerifyPassword isConfirmed ->
            ( { model | canRegister = False }
            , if isConfirmed then
                ChatApi.Users.create
                    { url = shared.baseUrl
                    , params = { username = model.username, password = model.password }
                    , handler = OnCreateUser
                    }
                    |> Effect.sendCmd

              else
                Effect.none
            )



-- SUBSCRIPTIONS


{-| -}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "登录"
    , body = [ loginForm model ]
    }


loginForm : Model -> Html Msg
loginForm model =
    [ W.Text.view
        [ W.Text.extraLarge, W.Text.aux ]
        [ Html.text "欢迎，请登录" ]
    , W.Modal.view [ W.Modal.absolute, W.Modal.noBlur ]
        { isOpen = model.canRegister
        , onClose = Nothing
        , content = [ dialogContent model ]
        }
    , W.InputField.view []
        { label = [ Html.text "账号" ]
        , input =
            [ W.InputText.view [ W.InputText.htmlAttrs [ attribute "id" usernameHtmlId ] ]
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
    , [ W.InputCheckbox.view []
            { value = model.rememberMe
            , onInput = SetRememberMe
            }
      , Html.text "记住我"
      ]
        |> W.Container.view [ W.Container.horizontal, W.Container.padY_4 ]
    , W.Text.view [ W.Text.color "red" ] [ Html.text model.errorMessage ]
    , W.Button.view []
        { label = [ Html.text "登录" ]
        , onClick = ClickSignIn Nothing
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


dialogContent : Model -> Html Msg
dialogContent model =
    [ W.Text.view [ W.Text.large ] [ Html.text "注册新账号" ]
    , W.InputField.view []
        { label = [ Html.text "请再次输入登录密码" ]
        , input =
            [ W.InputText.view
                [ W.InputText.password
                ]
                { value = model.rePassword
                , onInput = \new -> UpdateModel { model | rePassword = new }
                }
            ]
        }
    , [ W.Button.view
            [ W.Button.small
            , W.Button.disabled (not model.isSamePassword)
            ]
            { label =
                [ Html.text <|
                    if model.isSamePassword then
                        "确认"

                    else
                        "⭕校验密码不一致"
                ]
            , onClick = OnFinishVerifyPassword model.isSamePassword
            }
      , W.Button.view
            [ W.Button.small
            ]
            { label = [ Html.text "取消" ]
            , onClick = OnFinishVerifyPassword False
            }
      ]
        |> W.Container.view [ W.Container.horizontal, W.Container.gap_4 ]
    ]
        |> W.Container.view
            [ W.Container.fill
            , W.Container.alignCenterX
            , W.Container.gap_2
            , W.Container.pad_4
            ]
