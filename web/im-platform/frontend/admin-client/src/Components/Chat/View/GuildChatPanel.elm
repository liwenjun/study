module Components.Chat.View.GuildChatPanel exposing (view)

import Auth
import BoundedList
import ChatApi exposing (Message)
import Components.Chat.Model exposing (..)
import Components.Chat.Msg exposing (..)
import Components.Chat.Utils as Chat
import Components.Colors as Colors
import Components.Style exposing (style)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html.Attributes
import Markdown.Renderer.ElmUi as Renderer
import RemoteData exposing (RemoteData(..), WebData)
import Shared
import Utils



-- VIEW


{-| -}
view : ChatGuild -> Auth.User -> Shared.Model -> Model -> Element Msg
view guild user shared model =
    column
        [ width fill
        , height fill
        , paddingEach { right = 10, left = 10, top = 10, bottom = 0 }
        ]
        [ messagePanel guild shared model
        , inputPanel guild model
        , toolPanel guild model
        ]


{-| -}
messagePanel : ChatGuild -> Shared.Model -> Model -> Element Msg
messagePanel guild shared model =
    let
        messageEntry message =
            let
                preview markdownText =
                    case Renderer.defaultWrapped markdownText of
                        Ok element ->
                            element

                        Err _ ->
                            text "出错了!"
            in
            textColumn
                [ width fill, spacingXY 0 10, Font.size Chat.defaultFontSize ]
                [ row
                    [ spacingXY 10 0
                    , width <| fill -- px 200
                    , Border.widthEach { left = 0, right = 0, top = 0, bottom = 1 }
                    ]
                    [ text "✍️🗣️"
                    , messageAuthorName message |> text |> el [ Font.bold ]
                    , case message.nonce of
                        Just n ->
                            n |> text |> el [ Font.color Colors.red_500 ]

                        Nothing ->
                            none
                    , Utils.datetime message.id |> text |> el [ alignRight ]
                    , text "⏰" |> el [ alignRight ]
                    ]
                , preview message.content
                ]
    in
    guild.messages
        |> BoundedList.toList
        |> List.map messageEntry
        |> column
            [ width fill
            , height fill
            , paddingXY 0 10
            , spacingXY 0 30
            , scrollbarY
            , htmlAttribute <| Html.Attributes.id Chat.msgsViewHtmlId
            , Utils.onScroll <| OnMsgsViewEvent OnManualScrolled
            ]



--model.inputs


{-| -}
inputPanel : ChatGuild -> Model -> Element Msg
inputPanel guild model =
    el [ width fill, Font.size Chat.defaultFontSize ] <|
        Input.multiline
            [ height <| px 102
            , Utils.onEnter <| ClickSendMessage guild.guild.id
            , htmlAttribute <| Html.Attributes.id Chat.inputHtmlId
            , htmlAttribute <| Html.Attributes.autofocus True
            ]
            { onChange = \new -> UpdateModel { model | input = new }
            , text = model.input --"untag model.input"
            , placeholder = Nothing
            , label = Input.labelAbove [] none
            , spellcheck = False
            }


{-| -}
toolPanel : ChatGuild -> Model -> Element Msg
toolPanel guild model =
    row [ width fill, paddingXY 10 10, spacingXY 10 0 ]
        [ {- Input.button style.button
                 { onPress = Nothing -- ClickSendPersistentMessage guild.channel.id |> Just
                 , label = text "持久"
                 }
             ,
          -}
          text
            (case model.sendMember of
                Just member ->
                    "此消息将私发给【" ++ member.user.displayName ++ "】，其他成员不可见。"

                Nothing ->
                    -- "在【" ++ guild.guild.name ++ "】中群聊"
                    "群聊"
            )
            |> el [ Font.size 16, Background.color <| rgb255 0xC1 0xF1 0xD1, paddingXY 10 3 ]
        , Input.button style.smallButton
            { onPress = ClickSendMessage guild.guild.id |> Just
            , label = text "发送 (Enter)"
            }
            |> el [ alignRight ]
        ]


{-| -}
messageAuthorName : Message -> String
messageAuthorName a =
    case a.author of
        ChatApi.AUser u ->
            u.displayName

        ChatApi.AMember m ->
            m.user.displayName
