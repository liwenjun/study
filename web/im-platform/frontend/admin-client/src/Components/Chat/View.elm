module Components.Chat.View exposing (view)

--import Markdown.Block exposing (HtmlAttribute)
--import FontAwesome.Svg as SvgIcon
--import Html

import Auth
import Components.Chat.Model exposing (..)
import Components.Chat.Msg exposing (..)
import Components.Chat.Utils as Chat
import Components.Chat.View.ErrorPanel as ErrorPanel
import Components.Chat.View.GuildChatPanel as GuildChatPanel
import Components.Chat.View.GuildSettingPanel as GuildSettingPanel
import Components.Chat.View.ListGuildPanel as ListGuildPanel
import Components.Chat.View.ListMemberPanel as ListMemberPanel
import Components.Dialog as Dialog
import Components.Style exposing (dialogConfig, style)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Shared
import Components.Colors as Colors



-- VIEW


{-| -}
view : Auth.User -> Shared.Model -> Model -> Element Msg
view user shared model =
    let
        dialog =
            case model.nameChangeStatus of
                NotChanging ->
                    Nothing

                ChangingTo new ->
                    changeNameDialogConfig new model |> Just

        dialog3 =
            if model.canCreateGuild then
                createGuildDialogConfig model |> Just

            else
                Nothing
    in
    row [ width fill, height fill, centerX ]
        [ case model.chatMode of
            JoinOrCreateGuild ->
                GuildSettingPanel.view user shared model

            ChatInGuild guild ->
                case Chat.getSelectedGuild guild model.guilds of
                    Just guild_ ->
                        GuildChatPanel.view guild_ user shared model

                    Nothing ->
                        ErrorPanel.view user shared model
        , column
            [ width <| px 300
            , height fill
            , paddingXY 10 10
            , spacingXY 0 10
            , scrollbarY
            , Background.color Colors.slate_200
            , Border.widthEach { left = 2, right = 0, top = 0, bottom = 0 }
            ]
            [ -- 群组列表
              ListGuildPanel.view user shared model
            , -- 成员列表
              case model.chatMode of
                JoinOrCreateGuild ->
                    none

                ChatInGuild guild ->
                    case Chat.getSelectedGuild guild model.guilds of
                        Just guild_ ->
                            ListMemberPanel.view guild_ user shared model

                        Nothing ->
                            none

            -- memberListPanel model
            ]

        --ListGuildPanel.view user shared model
        ]
        |> el
            [ width fill
            , height fill
            , inFront (Dialog.view dialog)
            , inFront (Dialog.view dialog3)
            ]


changeNameDialogConfig : String -> Model -> Dialog.Config Msg
changeNameDialogConfig str model =
    dialogConfig
        { closeMessage = OnFinishNameChange False |> Just
        , header = text "请输入实名" |> Just
        , body =
            column [ width fill ]
                [ Input.text style.textInput
                    { onChange = \new -> UpdateModel { model | nameChangeStatus = ChangingTo new }
                    , text = str
                    , placeholder = Nothing
                    , label = Input.labelBelow [] (text "新名称下次登录生效。")
                    }
                    |> el [ centerX ]
                ]
                |> Just
        , footer =
            row [ centerX, spacingXY 40 0 ]
                [ Input.button style.button
                    { onPress = OnFinishNameChange True |> Just
                    , label = text "⭕确认"
                    }
                ]
                |> Just
        }


{-
leaveGuildDialogConfig : Model -> Dialog.Config Msg
leaveGuildDialogConfig model =
    dialogConfig
        { closeMessage = OnFinishLeaveGuild False |> Just
        , header = text "确实要退群吗" |> Just
        , body = Nothing
        , footer =
            row [ centerX, spacingXY 40 0 ]
                [ Input.button style.button
                    { onPress = OnFinishLeaveGuild True |> Just
                    , label = text "⭕确认"
                    }
                ]
                |> Just
        }
-}

createGuildDialogConfig : Model -> Dialog.Config Msg
createGuildDialogConfig model =
    dialogConfig
        { closeMessage = OnFinishCreateGuild False |> Just
        , header = text "创建新群" |> Just
        , body =
            column [ width fill ]
                [ Input.text style.textInput
                    { onChange = \new -> UpdateModel { model | guildName = new }
                    , text = model.guildName
                    , placeholder = Nothing
                    , label = Input.labelHidden ""
                    }
                    |> el [ centerX ]
                ]
                |> Just
        , footer =
            row [ centerX, spacingXY 40 0 ]
                [ Input.button style.button
                    { onPress = OnFinishCreateGuild True |> Just
                    , label = text "⭕确认"
                    }
                ]
                |> Just
        }
