module Components.Chat.View exposing (view)

{-| -}

import Auth
import Components.Chat.Model as Chat exposing (..)
import Components.Chat.Msg as Chat exposing (..)
import Components.Chat.Utils as Chat
import Components.Chat.View.ErrorPanel as ErrorPanel
import Components.Chat.View.GuildChatPanel as GuildChatPanel
import Components.Chat.View.GuildSettingPanel as GuildSettingPanel
import Components.Chat.View.ListGuildPanel as ListGuildPanel
import Components.Chat.View.ListMemberPanel as ListMemberPanel
import Components.Chat.View.UserInfoPanel as UserInfoPanel
import Html exposing (Html)
import Html.Attributes exposing (style)
import Shared
import Theme
import W.Container
import W.Divider
import W.Text



--import Components.Chat.View.ListMemberPanel as ListMemberPanel
-- VIEW


{-| -}
view : Auth.User -> Shared.Model -> Model -> Html Msg
view user shared model =
    [ leftPanel user shared model
    , W.Divider.view [ W.Divider.vertical ] []
    , rightPanel user shared model
    ]
        |> W.Container.view
            [ W.Container.horizontal
            , W.Container.alignRight
            , W.Container.background (Theme.baseBackgroundWithAlpha 0.9)
            , W.Container.styleAttrs [ ( "height", "100%" ) ]
            ]


leftPanel : Auth.User -> Shared.Model -> Model -> Html Msg
leftPanel user shared model =
    [ case model.chatMode of
        JoinOrCreateGuild ->
            GuildSettingPanel.view user shared model

        ChatInGuild guild ->
            case Chat.getSelectedGuild guild model.guilds of
                Just guild_ ->
                    GuildChatPanel.view guild_ user shared model

                Nothing ->
                    ErrorPanel.view user shared model
    ]
        |> W.Container.view
            [ W.Container.alignBottom
            , W.Container.fill
            , W.Container.background (Theme.successBackgroundWithAlpha 0.1)
            , W.Container.styleAttrs
                [ ( "height", "100%" )
                , ( "max-width", "938px" )
                , ( "width", "100%" )
                ]
            ]


rightPanel : Auth.User -> Shared.Model -> Model -> Html Msg
rightPanel user shared model =
    let
        memberPanel =
            case model.chatMode of
                JoinOrCreateGuild ->
                    Html.div [] []

                ChatInGuild guild ->
                    case Chat.getSelectedGuild guild model.guilds of
                        Just guild_ ->
                            ListMemberPanel.view guild_ user shared model

                        Nothing ->
                            Html.div [] []
    in
    [ UserInfoPanel.view user shared model
    , ListGuildPanel.view user shared model
    , memberPanel
    ]
        |> W.Container.view
            [ W.Container.fill
            , W.Container.vertical
            , W.Container.gap_4
            ]
        |> List.singleton
        |> W.Container.view
            [ W.Container.fill
            , W.Container.horizontal
            , W.Container.background (Theme.baseAuxWithAlpha 0.05)
            , W.Container.styleAttrs [ ( "overflow", "auto" ), ( "height", "100%" ), ( "width", "260px" ) ]
            ]
