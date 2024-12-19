module Components.Chat.View.GuildSettingPanel exposing (view)

{-| -}

import Auth
import Components.Chat.Model exposing (..)
import Components.Chat.Msg exposing (..)
import Html exposing (Html)
import Shared
import Theme
import W.Button
import W.Container
import W.DataRow
import W.InputText
import W.Modal
import W.Text



-- VIEW


{-| -}
view : Auth.User -> Shared.Model -> Model -> Html Msg
view user shared model =
    [ titlePanel
    , listPanel user model
    , list0Panel user model
    , W.Modal.view [ W.Modal.absolute, W.Modal.noBlur ]
        { isOpen = model.canCreateGuild
        , onClose = Nothing
        , content = [ createGuildDialogContent model ]
        }
    ]
        |> W.Container.view [ W.Container.fill ]


list0Panel user model =
    model.otherGuilds
        |> List.map
            (\x ->
                W.DataRow.view
                    [ W.DataRow.noBackground
                    , W.DataRow.href ""
                    , W.DataRow.paddingY 1
                    , W.DataRow.right
                        [ W.Button.view [ W.Button.small ]
                            { label = [ Html.text "加群" ]
                            , onClick = ClickJoinGuild x.id
                            }
                        ]
                    ]
                    [ Html.text x.name
                    ]
            )
        |> W.Container.view
            [ W.Container.fill
            , W.Container.padX_6
            , W.Container.background (Theme.baseBackgroundWithAlpha 0.8)
            ]


listPanel user model =
    model.guilds
        |> List.map
            (\x ->
                W.DataRow.view
                    [ W.DataRow.noBackground
                    , W.DataRow.paddingY 0
                    , W.DataRow.right <|
                        if x.guild.ownerId /= user.user.id then
                            [ W.Button.view
                                [ W.Button.small
                                , W.Button.warning
                                ]
                                { label = [ Html.text "退群" ]
                                , onClick = ClickLeaveGuild x.guild.id
                                }
                            ]

                        else
                            []
                    ]
                    [ Html.text x.guild.name
                    ]
            )
        |> W.Container.view
            [ W.Container.fill
            ]


titlePanel =
    [ W.Text.view
        [ W.Text.large, W.Text.aux ]
        [ Html.text "可加群组" ]
    , [ W.Button.view
            [ W.Button.small
            ]
            { label = [ Html.text "建群" ]
            , onClick = ClickCreateGuild
            }
      ]
        |> W.Container.view [ W.Container.alignRight, W.Container.fill, W.Container.padRight_2 ]
    ]
        |> W.Container.view
            [ W.Container.fill
            , W.Container.pad_2
            , W.Container.horizontal
            , W.Container.alignBottom
            , W.Container.background (Theme.baseAuxWithAlpha 0.1)
            ]


createGuildDialogContent : Model -> Html Msg
createGuildDialogContent model =
    [ W.Text.view [ W.Text.large ] [ Html.text "创建新群" ]
    , W.InputText.view
        []
        { value = model.guildName
        , onInput = \new -> UpdateModel { model | guildName = new }
        }
    , [ W.Button.view
            [ W.Button.small
            ]
            { label =
                [ Html.text "确认" ]
            , onClick = OnFinishCreateGuild True
            }
      , W.Button.view
            [ W.Button.small
            ]
            { label = [ Html.text "取消" ]
            , onClick = OnFinishCreateGuild False
            }
      ]
        |> W.Container.view [ W.Container.horizontal, W.Container.gap_4 ]
    ]
        |> W.Container.view
            [ W.Container.fill
            , W.Container.alignCenterX
            , W.Container.gap_2
            , W.Container.pad_4
            ]
