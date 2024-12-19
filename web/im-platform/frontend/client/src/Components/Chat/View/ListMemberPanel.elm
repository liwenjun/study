module Components.Chat.View.ListMemberPanel exposing (view)

import Auth
import ChatApi as Api exposing (UserStatus)
import Components.Chat.Model  exposing (..)
import Components.Chat.Msg exposing (..)
import Html exposing (Html)
import Html.Events
import Shared
import Theme
import W.Button
import W.Container
import W.Text



-- VIEW


{-| -}
view : ChatGuild -> Auth.User -> Shared.Model -> Model -> Html Msg
view guild user shared model =
    [ titlePanel
    , listPanel guild
    ]
        |> W.Container.view
            [ W.Container.fill
            ]


listPanel guild =
    guild.members
        |> List.map
            (\x ->
                W.Button.viewDummy
                    [ presenceToColor x.user.presence
                    , if isOnline x.user.presence then
                        W.Button.htmlAttrs
                            [ Html.Events.onDoubleClick <| ClickSelectedMember x
                            ]

                      else
                        W.Button.noAttr
                    ]
                    [ Html.text x.user.displayName ]
            )
        |> W.Container.view
            [ W.Container.horizontal
            , W.Container.fill
            , W.Container.gap_2
            , W.Container.pad_2
            ]


titlePanel =
    [ W.Text.view
        [ W.Text.large, W.Text.aux ]
        [ Html.text "成员" ]
    ]
        |> W.Container.view
            [ W.Container.fill
            , W.Container.pad_2
            , W.Container.background (Theme.baseAuxWithAlpha 0.1)
            ]


isOnline : Maybe UserStatus -> Bool
isOnline s =
    s
        |> Maybe.map (\x -> x == Api.Online)
        |> Maybe.withDefault False


presenceToColor : Maybe UserStatus -> W.Button.Attribute msg
presenceToColor s =
    case s of
        Just status ->
            case status of
                Api.Online ->
                    W.Button.success

                Api.Away ->
                    W.Button.warning

                Api.Busy ->
                    W.Button.secondary

                Api.Offline ->
                    W.Button.theme
                        { foreground = Theme.baseAuxWithAlpha 0.1
                        , background = Theme.baseAuxWithAlpha 0.1
                        , aux = "grey"
                        }

        Nothing ->
            W.Button.danger
