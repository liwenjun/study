module Components.Chat.View.GuildSettingPanel exposing (view)

--import Markdown.Block exposing (HtmlAttribute)
--import FontAwesome.Svg as SvgIcon
--import Html

--import Api.Model
import Auth
import Components.Chat.Model exposing (..)
import Components.Chat.Msg exposing (..)
import Components.Chat.Utils as Chat
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
view : Auth.User -> Shared.Model -> Model -> Element Msg
view user shared model =
    column
        [ width fill
        , height fill
        , paddingEach { right = 10, left = 10, top = 10, bottom = 0 }
        ]
        [ guildListPanel user model ]


{-| -}
guildListPanel : Auth.User -> Model -> Element Msg
guildListPanel user model =
    textColumn [ width fill, paddingXY 20 10 ]
        [ row [ width fill ]
            [ paragraph [ Font.size 20 ] [ text "可用清单" ]
            , Input.button style.smallButton
                { onPress = ClickCreateGuild |> Just
                , label = text "创建新群"
                }
                |> el [ alignRight ]
            ]
        , column
            [ height fill
            , paddingEach { top = 20, bottom = 0, left = 0, right = 0 }
            , spacingXY 0 2
            , width fill
            , Font.size Chat.defaultFontSize
            , Border.widthEach { top = 2, bottom = 0, left = 0, right = 0 }
            ]
          <|
            List.map
                (\x ->
                    row [ width fill ]
                        [ paragraph [] [ text x.name ]
                        , Input.button style.smallButton
                            { onPress = ClickJoinGuild x.id |> Just
                            , label = text "加群"
                            }
                            |> el [ alignRight ]
                        ]
                        |> el
                            [ width fill
                            , paddingXY 2 5
                            , mouseDown [ Background.color <| rgb255 0x40 0x80 0x40 ]
                            , mouseOver [ Background.color <| rgb255 0x80 0xC0 0x80 ]
                            , focused [ Background.color <| rgb255 0xC0 0xC0 0x40 ]
                            --, onClick <| ClickJoinGuild x.id
                            ]
                )
                model.otherGuilds
        ]

