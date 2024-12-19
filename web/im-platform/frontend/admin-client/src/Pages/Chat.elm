module Pages.Chat exposing (Model, Msg, page)

--import Api.Websocket as Ws

import Auth
import Browser.Dom as Dom
import ChatApi as Api exposing (decoderWebsocketMessageValue)
import ChatApi.Guilds
import ChatApi.Users
import Components.Chat.Model as Chat exposing (..)
import Components.Chat.Msg as Chat exposing (..)
import Components.Chat.Utils as Chat
import Components.Chat.View as Chat
import Effect exposing (Effect)
import Json.Encode
import Jsonrpc exposing (RpcData, toResult)
import List.Extra
import Maybe.Extra
import Page exposing (Page)
import Ports
import RemoteData exposing (RemoteData(..))
import Route exposing (Route)
import Shared
import Task
import Utils
import View exposing (View)


{-| -}
type alias Model =
    Chat.Model


{-| -}
type alias Msg =
    Chat.Msg


{-| -}
page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init user shared
        , update = update user shared
        , subscriptions = subscriptions
        , view = view user shared
        }



-- INIT


init : Auth.User -> Shared.Model -> () -> ( Model, Effect Msg )
init user shared () =
    ( initModel
    , Effect.openWebsocketServer
        { url = shared.wsServer
        , data =
            Json.Encode.object
                [ ( "event", Json.Encode.string "IDENTIFY" )
                , ( "data", Json.Encode.object [ ( "token", Json.Encode.string user.token.token ) ] )
                ]
        }
    )



-- UPDATE


{-| -}
update : Auth.User -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update user shared msg model =
    case msg of
        SetRenderMarkdown bool ->
            ( { model | renderMarkdown = bool }, Effect.none )

        NoOP ->
            ( model, Effect.none )

        SetInputFocused ->
            ( model, Utils.setFocus Chat.inputHtmlId NoOP )

        UpdateModel m ->
            ( m, Effect.none )

        ClickSelectedGuild guild ->
            ( { model
                | selectedGuild = guild
                , sendMember = Nothing
                , chatMode = Chat.ChatInGuild guild
              }
            , Effect.batch
                [ Effect.saveGuild guild
                , Utils.setFocus Chat.msgsViewHtmlId SetInputFocused
                ]
            )

        ClickSelectedMember member ->
            ( { model | sendMember = Just member }, Effect.none )

        ClickSendMessage g ->
            if (model.input |> String.trim |> String.length) == 0 then
                ( { model | input = "" }, Effect.none )

            else
                ( { model | input = "" }
                , Effect.batch
                    [ Effect.sendWebsocketMessage
                        { userId = user.user.id
                        , guildId = g
                        , message = model.input
                        , memberId = model.sendMember |> Maybe.andThen (\x -> Just x.user.id)
                        }
                    , Chat.snapScrollChatMsgsView
                    ]
                )

        ClickSendPersistentMessage g ->
            if (model.input |> String.trim |> String.length) == 0 then
                ( { model | input = "" }, Effect.none )

            else
                ( { model | input = "" }
                , Effect.batch
                    [ ChatApi.Guilds.sendMessage
                        { url = shared.baseUrl
                        , token = user.token.token |> Just
                        , params = { guildId = g, content = model.input, nonce = Nothing }
                        , handler = HandleMessage
                        }
                        |> Effect.sendCmd
                    , Chat.snapScrollChatMsgsView
                    ]
                )

        HandleMessage data ->
            ( model, Effect.none )

        OnChangeName name ->
            ( model, Effect.none )

        OnFinishNameChange isConfirmed ->
            case model.nameChangeStatus of
                ChangingTo newNameInput ->
                    -- Reset model if user cancels.
                    if not isConfirmed then
                        ( { model | nameChangeStatus = NotChanging }
                        , Effect.none
                        )

                    else
                    -- Do nothing if new name input is empty.
                    if
                        String.isEmpty newNameInput
                    then
                        ( model, Effect.none )

                    else
                        ( { model | nameChangeStatus = NotChanging }
                        , ChatApi.Users.changeDisplayName
                            { url = shared.baseUrl
                            , token = user.token.token |> Just
                            , params = newNameInput
                            , handler = OnChangeName
                            }
                            |> Effect.sendCmd
                        )

                -- TODO: Handle impossible case?
                NotChanging ->
                    ( model, Effect.none )

        OnMsgsViewEvent event ->
            case event of
                TriedSnapScroll result ->
                    ( model, Effect.none )

                OnManualScrolled ->
                    ( model
                    , (Task.attempt (OnMsgsViewEvent << GotViewport) <|
                        Dom.getViewportOf Chat.msgsViewHtmlId
                      )
                        |> Effect.sendCmd
                    )

                GotViewport result ->
                    case result of
                        Err _ ->
                            ( model, Effect.none )

                        Ok viewport ->
                            ( { model
                                | hasManualScrolledUp = Utils.hasManualScrolledUp viewport
                              }
                            , Effect.none
                            )

        OnRecieveWsmessage data ->
            case decoderWebsocketMessageValue data of
                Api.Text message ->
                    Chat.dispatch message user model

                Api.Close _ ->
                    ( model, Effect.signOut )

                _ ->
                    ( model, Effect.none )

        ClickLeaveGuild ->
            ( model, Effect.none )

        OnGetGuilds data ->
            ( case data |> toResult of
                Ok guilds ->
                    { model | otherGuilds = guilds }

                Err _ ->
                    model
            , Effect.none
            )

        ClickSelectOtherGuild ->
            ( { model
                | chatMode = JoinOrCreateGuild
                , selectedGuild = ""
              }
            , ChatApi.Users.getOtherGuilds
                { url = shared.baseUrl
                , token = user.token.token |> Just
                , handler = OnGetGuilds
                }
                |> Effect.sendCmd
            )

        ClickJoinGuild guild ->
            ( model
            , ChatApi.Guilds.join
                { url = shared.baseUrl
                , token = user.token.token |> Just
                , params = guild
                , handler = OnJoinGuild
                }
                |> Effect.sendCmd
            )

        OnJoinGuild data ->
            case data |> toResult of
                Ok member ->
                    ( { model
                        | otherGuilds =
                            model.otherGuilds
                                |> List.filter (\x -> x.id /= member.guildId)
                      }
                    , ClickSelectedGuild member.guildId
                        |> Task.succeed
                        |> Task.perform identity
                        |> Effect.sendCmd
                    )

                Err _ ->
                    ( model, Effect.none )

        OnCreateGuild data ->
            ( model
            , case data |> toResult of
                Ok guild ->
                    ClickSelectedGuild guild.id
                        |> Task.succeed
                        |> Task.perform identity
                        |> Effect.sendCmd

                Err _ ->
                    Effect.none
            )

        ClickCreateGuild ->
            ( { model | canCreateGuild = True }, Effect.none )

        OnFinishCreateGuild isConfirmed ->
            ( { model | canCreateGuild = False }
            , if isConfirmed then
                ChatApi.Guilds.create
                    { url = shared.baseUrl
                    , token = user.token.token |> Just
                    , params = { name = model.guildName }
                    , handler = OnCreateGuild
                    }
                    |> Effect.sendCmd

              else
                Effect.none
            )



-- SUBSCRIPTIONS


{-| -}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.subRecvWsmessage OnRecieveWsmessage
        ]



-- VIEW


view : Auth.User -> Shared.Model -> Model -> View Msg
view user shared model =
    { title = "交流平台"

    {-
       case model.selectedGuild of
           Just guild ->
               guild.name

           Nothing ->
               "交流平台"
    -}
    , attributes = []
    , element = Chat.view user shared model
    }
