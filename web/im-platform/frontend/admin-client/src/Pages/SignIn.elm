module Pages.SignIn exposing (Model, Msg, page)

{-|

@docs Model, Msg, page

-}

import ChatApi exposing (User, Token)
import ChatApi.Users
import Components.Dialog as Dialog
import Components.Style exposing (dialogConfig, style)
import Effect exposing (Effect)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Html.Attributes
import Jsonrpc exposing (RpcData, toResult)
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Utils
import View exposing (View)
import Components.Colors as Colors


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


{-| -}
view : Model -> View Msg
view model =
    { title = "登录"
    , attributes = []
    , element = loginForm model
    }


{-| -}
loginForm : Model -> Element Msg
loginForm model =
    let
        dialog =
            if model.canRegister then
                registerDialogConfig model |> Just

            else
                Nothing
    in
    column
        [ centerX
        , centerY
        , Border.width 1
        , Border.rounded 5
        , Background.color Colors.slate_200
        , padding 30
        , spacing 20
        ]
        [ el (centerX :: style.text 36) <| text "请登录"
        , Input.username ((htmlAttribute <| Html.Attributes.id usernameHtmlId) :: style.textInput)
            { onChange = \new -> UpdateModel { model | username = new }
            , text = model.username
            , placeholder = Just <| Input.placeholder [] (text "账号")
            , label = Input.labelAbove (style.text 20) <| text "账号"
            }
        , Input.currentPassword style.textInput
            { onChange = \new -> UpdateModel { model | password = new }
            , text = model.password
            , placeholder = Just <| Input.placeholder [] (text "密码")
            , label = Input.labelAbove (style.text 20) <| text "密码"
            , show = False
            }
        , Input.checkbox []
            { onChange = SetRememberMe
            , icon = Input.defaultCheckbox
            , checked = model.rememberMe
            , label = Input.labelRight (style.text 16) <| text "记住我"
            }
        , Input.button (centerX :: style.button)
            { onPress = ClickSignIn Nothing |> Just, label = text "🧑🏻‍🤝‍🧑🏼登录" }
        , el (style.text 16) <| text model.errorMessage
        ]
        |> el [ width fill, height fill, inFront (Dialog.view dialog) ]


registerDialogConfig : Model -> Dialog.Config Msg
registerDialogConfig model =
    dialogConfig
        { closeMessage = OnFinishVerifyPassword False |> Just
        , header = text "注册新账号" |> Just
        , body =
            column [ width fill ]
                [ Input.newPassword style.textInput
                    { onChange = \new -> UpdateModel { model | rePassword = new }
                    , text = model.rePassword
                    , placeholder = Nothing
                    , label = Input.labelAbove [] <| text "如需注册该账号，请再次输入登录密码"
                    , show = False
                    }
                    |> el [ centerX ]
                ]
                |> Just
        , footer =
            row [ centerX, spacingXY 40 0 ]
                [ Input.button style.button
                    (if model.isSamePassword then
                        { onPress = OnFinishVerifyPassword True |> Just
                        , label = text "⭕确认"
                        }

                     else
                        { onPress = Nothing
                        , label = text "密码不一致"
                        }
                    )
                ]
                |> Just
        }
