module Components.Chat.View.ListGuildPanel exposing (view)

{-| -}

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
import Shared



-- VIEW


{-| -}
view : Auth.User -> Shared.Model -> Model -> Element Msg
view user shared model =
    column [ width fill ]
        [ -- 登录者姓名及修改按钮
          userShowPanel user model
        , -- 群组列表
          guildListPanel user model
        ]


{-| -}
userShowPanel : Auth.User -> Model -> Element Msg
userShowPanel user model =
    row [ width fill, paddingXY 10 10, Background.color <| rgb255 0xC1 0xF1 0xF8 ]
        [ paragraph [] [ text ("💖" ++ user.user.displayName) ]
        , Input.button style.smallButton
            { onPress = UpdateModel { model | nameChangeStatus = ChangingTo "" } |> Just
            , label = text "改名"
            }
            |> el [ alignRight ]
        ]


{-| -}
guildListPanel : Auth.User -> Model -> Element Msg
guildListPanel user model =
    textColumn [ width fill, paddingXY 0 10 ]
        [ row [ width fill ]
            [ paragraph [ Font.size 20 ] [ text "群组清单" ]
            , Input.button style.smallButton
                { onPress = ClickSelectOtherGuild |> Just
                , label = text "👨\u{200D}👩\u{200D}👦加群"
                }
                |> el [ alignRight ]
            ]
        , List.map
            (\x ->
                row [ width fill ]
                    [ paragraph [] [ text x.guild.name ]
                    , if (x.guild.id == model.selectedGuild) && (x.guild.ownerId /= user.user.id) then
                        Input.button style.smallButton
                            { onPress = ClickLeaveGuild |> Just
                            , label = text "❌退群"
                            }
                            |> el [ alignRight ]

                      else
                        none
                    ]
                    |> el
                        ([ width fill
                         , paddingXY 2 5
                         , mouseDown [ Background.color <| rgb255 0x40 0x80 0x40 ]
                         , mouseOver [ Background.color <| rgb255 0x80 0xC0 0x80 ]
                         , focused [ Background.color <| rgb255 0xC0 0xC0 0x40 ]

                         , onClick <| ClickSelectedGuild x.guild.id
                         ]
                            ++ (if x.guild.id == model.selectedGuild then
                                    [ Background.color <| rgb255 0xB0 0xE0 0xE0 ]

                                else
                                    []
                               )
                        )
            )
            model.guilds
            |> column
                [ height fill
                , paddingEach { top = 20, bottom = 0, left = 0, right = 0 }
                , spacingXY 0 2
                , width fill
                , Font.size Chat.defaultFontSize
                , Border.widthEach { top = 2, bottom = 0, left = 0, right = 0 }
                ]
        ]
