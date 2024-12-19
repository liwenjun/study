module Components.Chat.View.GuildChatPanel exposing (view)

import Auth
import BoundedList
import ChatApi as Api exposing (Message)
import Components.Chat.Model as Chat exposing (..)
import Components.Chat.Msg as Chat exposing (..)
import Components.Chat.Utils as Chat
import Html exposing (Html)
import Html.Attributes exposing (attribute, style)
import Markdown.Parser as Markdown
import Markdown.Renderer
import Maybe.Extra
import Shared
import Theme
import Utils
import W.Button
import W.Container
import W.Divider
import W.InputCheckbox
import W.InputTextArea
import W.Message
import W.Text



-- VIEW


{-| -}
view : ChatGuild -> Auth.User -> Shared.Model -> Model -> Html Msg
view guild user shared model =
    [ messagePanel guild shared model
    , W.Divider.view [] []
    , inputPanel guild model
    , toolsPanel guild model
    ]
        |> W.Container.view
            [ W.Container.alignBottom
            , W.Container.fill
            , W.Container.background (Theme.warningBackgroundWithAlpha 0.1)
            , W.Container.styleAttrs
                [ ( "height", "100%" )
                , ( "max-width", "938px" )
                , ( "width", "100%" )
                ]
            ]


messagePanel : ChatGuild -> Shared.Model -> Model -> Html Msg
messagePanel guild shared model =
    guild.messages
        |> BoundedList.toList
        |> List.map
            (\x ->
                [ messageHeader x
                , x.content
                    |> render model.renderMarkdown
                    |> W.Message.view
                        [ W.Message.htmlAttrs [ style "line-break" "anywhere" ]
                        , if Maybe.Extra.isNothing x.nonce then
                            W.Message.primary

                          else
                            W.Message.secondary
                        ]
                ]
                    |> Html.span []
            )
        --|> List.concat
        |> W.Container.view [ W.Container.fill, W.Container.gap_2 ]
        |> List.singleton
        |> W.Container.view
            [ W.Container.fill
            , W.Container.padX_4
            , W.Container.padY_2
            , W.Container.alignBottom
            , W.Container.horizontal
            , W.Container.styleAttrs
                [ ( "overflow", "auto" )
                , ( "height", "10px" )
                , ( "max-width", "938px" )
                ]
            , W.Container.htmlAttrs [ attribute "id" Chat.msgsViewHtmlId ]
            ]


inputPanel : ChatGuild -> Model -> Html Msg
inputPanel guild model =
    [ W.InputTextArea.view
        [ W.InputTextArea.autofocus
        , W.InputTextArea.rows 4
        , W.InputTextArea.onBlur SetInputFocused
        , W.InputTextArea.htmlAttrs [ attribute "id" Chat.inputHtmlId, Utils.onEnter <| ClickSendMessage guild.guild.id ]
        ]
        { value = model.input
        , onInput = \new -> UpdateModel { model | input = new }
        }
    ]
        |> W.Container.view
            [ W.Container.alignCenterX
            , W.Container.gap_2
            , W.Container.padX_4
            , W.Container.padTop_2
            ]


toolsPanel : ChatGuild -> Model -> Html Msg
toolsPanel guild model =
    let
        text =
            case model.sendMember of
                Just member ->
                    "此消息将私发给【" ++ member.user.displayName ++ "】，其他成员不可见。"

                Nothing ->
                    -- "在【" ++ guild.guild.name ++ "】中群聊"
                    "群聊"
    in
    [ Html.text text
    , [ {-
           W.InputCheckbox.view []
                       { value = model.renderMarkdown
                       , onInput = SetRenderMarkdown
                       }
                 ,
        -}
        W.Button.view
            [ W.Button.small ]
            { label = [ Html.text "发送" ]
            , onClick = ClickSendMessage guild.guild.id
            }
      ]
        |> W.Container.view
            [ W.Container.horizontal
            , W.Container.alignRight
            , W.Container.fill
            , W.Container.padRight_0
            ]
    ]
        |> W.Container.view
            [ W.Container.horizontal
            , W.Container.gap_4
            , W.Container.padX_6
            , W.Container.padY_2
            ]



-- Utils


messageHeader : Message -> Html msg
messageHeader x =
    [ Html.text "✍️"
    , Html.text (messageAuthorName x)
    , case x.nonce of
        Just n ->
            Html.text (" - " ++ n)

        Nothing ->
            Html.span [] []
    , [ Html.text (Utils.datetime x.id)
      , Html.text "⏰"
      ]
        |> W.Container.view
            [ W.Container.fill
            , W.Container.horizontal
            , W.Container.alignRight
            ]
    ]
        |> W.Container.view
            [ W.Container.fill
            , W.Container.padX_0
            , W.Container.padY_2
            , W.Container.horizontal
            ]


{-| -}
render : Bool -> String -> List (Html msg)
render isMarkdown text =
    if isMarkdown then
        case
            text
                |> Markdown.parse
                |> Result.mapError deadEndsToString
                |> Result.andThen (\ast -> Markdown.Renderer.render Markdown.Renderer.defaultHtmlRenderer ast)
        of
            Ok rendered ->
                rendered

            Err errors ->
                [ Html.text errors ]

    else
        text |> Html.text |> List.singleton


{-| -}
messageAuthorName : Message -> String
messageAuthorName a =
    case a.author of
        Api.AUser u ->
            u.displayName

        Api.AMember m ->
            m.user.displayName


deadEndsToString deadEnds =
    deadEnds
        |> List.map Markdown.deadEndToString
        |> String.join "\n"
