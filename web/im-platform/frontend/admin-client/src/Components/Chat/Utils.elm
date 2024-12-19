module Components.Chat.Utils exposing (..)

{-| -}

--import Api.Model exposing (Guild, Member, Message)

import Auth
import BoundedList
import Browser.Dom as Dom
import ChatApi as Ws exposing (WebsocketEvent)
import Components.Chat.Model as Chat exposing (..)
import Components.Chat.Msg as Chat exposing (..)
import Effect exposing (Effect)
import List.Extra
import Maybe.Extra
import Task


{-| -}
maxMessages : Int
maxMessages =
    100


{-| -}
msgsViewHtmlId : String
msgsViewHtmlId =
    "chat-msgs-view"


{-| -}
inputHtmlId : String
inputHtmlId =
    "chat-input"


{-| -}
defaultFontSize : Int
defaultFontSize =
    16



-- UTILs


{-| -}
getSelectedGuild : String -> List ChatGuild -> Maybe ChatGuild
getSelectedGuild guild guilds =
    guilds
        |> List.filter (\x -> x.guild.id == guild)
        |> List.head


{-| -}
guildToGuildName : String -> List ChatGuild -> String
guildToGuildName ch guilds =
    guilds
        |> List.filter (\x -> x.guild.id == ch)
        |> List.head
        |> Maybe.map (\x -> x.guild.name)
        |> Maybe.withDefault "未知"


{-| -}
snapScrollChatMsgsView : Effect Msg
snapScrollChatMsgsView =
    Dom.getViewportOf msgsViewHtmlId
        |> Task.andThen
            (\viewport ->
                Dom.setViewportOf msgsViewHtmlId 0 viewport.scene.height
            )
        |> (Task.attempt <| OnMsgsViewEvent << TriedSnapScroll)
        |> Effect.sendCmd


{-| Websocket
-}
dispatch : WebsocketEvent -> Auth.User -> Model -> ( Model, Effect Msg )
dispatch event user model =
    case event of
        Ws.Ready data ->
            -- 就绪
            case List.head data.guilds of
                Just guild ->
                    ( { model
                        | selectedGuild = guild.id
                        , chatMode = Chat.ChatInGuild guild.id
                      }
                    , Effect.saveGuild guild.id
                    )

                Nothing ->
                    ( model, Effect.none )

        Ws.GuildCreate data ->
            -- 加群
            let
                guild_ =
                    { guild = data.guild
                    , members = List.filter (\x -> x.user.id /= user.user.id) data.members
                    , messages = BoundedList.empty maxMessages
                    }
            in
            ( { model | guilds = guild_ :: model.guilds }, Effect.none )

        Ws.GuildRemove data ->
            -- 退群
            let
                guilds =
                    model.guilds |> List.filter (\x -> x.guild.id /= data.id)

                selected =
                    guilds
                        |> List.head
                        |> Maybe.map (\x -> x.guild.id)
                        |> Maybe.withDefault ""
            in
            ( { model
                | guilds = guilds
                , selectedGuild = selected

                {- , chatMode =
                   if selected == "" then
                       JoinOrCreateGuild

                   else
                       ChatInGuild selected
                -}
              }
            , Effect.none
            )

        Ws.MessageCreate data ->
            -- 新消息
            ( { model
                | guilds =
                    model.guilds
                        |> List.Extra.updateIf
                            (\x -> x.guild.id == data.guildId)
                            (\x -> { x | messages = x.messages |> BoundedList.addLast data })
                        |> List.Extra.updateIf
                            -- 来自其他群的私信
                            (\x ->
                                Maybe.Extra.isJust data.nonce
                                    && (x.guild.id == model.selectedGuild)
                                    && (x.guild.id /= data.guildId)
                            )
                            (\x ->
                                { x
                                    | messages =
                                        x.messages
                                            |> BoundedList.addLast
                                                { data
                                                    | nonce =
                                                        "发自【"
                                                            ++ guildToGuildName data.guildId model.guilds
                                                            ++ "】群的私信"
                                                            |> Just
                                                }
                                }
                            )
              }
            , if List.any (\x -> x.guild.id == data.guildId) model.guilds then
                snapScrollChatMsgsView

              else
                Effect.none
            )

        Ws.MemberCreate data ->
            ( { model
                | guilds =
                    model.guilds
                        |> List.map
                            (\x ->
                                if x.guild.id == data.guildId then
                                    { x | members = data :: x.members }

                                else
                                    x
                            )
              }
            , Effect.none
            )

        Ws.PresenceUpdate data ->
            -- 更新成员状态
            ( { model
                | guilds =
                    model.guilds
                        |> List.map
                            (\x ->
                                { x
                                    | members =
                                        x.members
                                            |> List.map
                                                (\y ->
                                                    let
                                                        u =
                                                            y.user

                                                        user_ =
                                                            { u
                                                                | presence =
                                                                    if u.id == data.userId then
                                                                        Just data.presence

                                                                    else
                                                                        u.presence
                                                            }
                                                    in
                                                    { y | user = user_ }
                                                )
                                }
                            )
              }
            , Effect.none
            )

        Ws.Other title data ->
            ( model, Effect.none )
