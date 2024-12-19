module Components.Chat.View.ListMemberPanel exposing (view)

import ChatApi exposing (UserStatus)
import Auth
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
import Shared



-- VIEW


{-| -}
view : ChatGuild -> Auth.User -> Shared.Model -> Model -> Element Msg
view guild user shared model =
    textColumn [ width fill, paddingXY 0 10 ]
        [ paragraph [ Font.size 20 ] [ text "成员清单" ]
        , wrappedRow
            [ height fill
            , width fill
            , paddingEach { top = 20, bottom = 0, left = 0, right = 0 }
            , spacingXY 10 5
            , Font.size Chat.defaultFontSize
            , Border.widthEach { top = 2, bottom = 0, left = 0, right = 0 }
            ]
          <|
            List.map
                (\x ->
                    text x.user.displayName
                        |> el
                            ([ paddingXY 10 5
                             , mouseDown [ Background.color <| rgb255 0x40 0x80 0x40 ]
                             , mouseOver [ Background.color <| rgb255 0x80 0xC0 0x80 ]
                             , focused [ Background.color <| rgb255 0xC0 0xC0 0x40 ]
                             , Background.color <| presenceToColor x.user.presence
                             , Border.rounded 5
                             ]
                                ++ (if isOnline x.user.presence then
                                        [ onDoubleClick <| ClickSelectedMember x ]

                                    else
                                        []
                                   )
                            )
                )
                guild.members
        ]


{-| -}
presenceToColor : Maybe UserStatus -> Color
presenceToColor s =
    case s of
        Just status ->
            case status of
                ChatApi.Online ->
                    Colors.green_300

                ChatApi.Away ->
                    Colors.cyan_300

                ChatApi.Busy ->
                    Colors.amber_300

                ChatApi.Offline ->
                    Colors.slate_300

        Nothing ->
            Colors.red_300


{-| -}
isOnline : Maybe UserStatus -> Bool
isOnline s =
    s
        |> Maybe.map (\x -> x == ChatApi.Online)
        |> Maybe.withDefault False
