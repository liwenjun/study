module Components.Chat.View.ListGuildPanel exposing (view)

import Auth
import Components.Chat.Model exposing (..)
import Components.Chat.Msg exposing (..)
import Html exposing (Html)
import Html.Attributes exposing (style)
import Shared
import Theme
import W.Button
import W.Container
import W.DataRow
import W.Text



-- VIEW


{-| -}
view : Auth.User -> Shared.Model -> Model -> Html Msg
view user shared model =
    [ titlePanel
    , listPanel user model
    ]
        |> W.Container.view [ W.Container.fill ]


listPanel user model =
    model.guilds
        |> List.map
            (\x ->
                W.DataRow.view
                    [ W.DataRow.onClick <| ClickSelectedGuild x.guild.id
                    , if x.guild.id == model.selectedGuild then
                        W.DataRow.htmlAttrs [ style "background-color" "#d0e0c0" ]

                      else
                        W.DataRow.noBackground
                    , W.DataRow.paddingY 0
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
        [ Html.text "群组" ]
    , [ W.Button.view
            [ W.Button.small
            ]
            { label = [ Html.text "设置" ]
            , onClick = ClickSelectOtherGuild
            }
      ]
        |> W.Container.view [ W.Container.alignRight, W.Container.fill, W.Container.padRight_2 ]
    ]
        |> W.Container.view
            [ W.Container.fill
            , W.Container.pad_2
            , W.Container.horizontal
            , W.Container.background (Theme.baseAuxWithAlpha 0.1)
            ]
