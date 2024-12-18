module View exposing (..)

import Bulma.Classes as B
import Bulma.Helpers as BH
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model as M
import VitePluginHelper



-- VIEW


layout : M.Model -> Html M.Msg
layout model =
    if List.isEmpty model.news then
        loading

    else
        listlayout model


loading : Html msg
loading =
    div [ class B.card ]
        [ div [ class B.cardImage ]
            [ figure [ class B.image ]
                [ img [ src <| VitePluginHelper.asset "/src/assets/title.jfif", alt "image" ] []
                ]
            ]
        , div [ class B.cardContent ]
            [ div [ class B.media ]
                [ div [ class B.mediaContent ]
                    [ p [ BH.classList [ B.title, B.is4 ] ] [ text "检索新闻列表..." ]
                    , p [ BH.classList [ B.subtitle, B.is6 ] ]
                        [ progress [ BH.classList [ B.progress, B.isMedium, B.isPrimary ] ] []
                        ]
                    ]
                ]
            ]
        ]


loading1 : Html msg
loading1 =
    section [ class B.hero ]
        [ div [ class B.heroBody ]
            [ p [ class B.title ] [ text "检索新闻列表..." ]
            , p [ class B.subtitle ]
                [ progress [ BH.classList [ B.progress, B.isLarge, B.isPrimary ] ] []
                ]
            ]
        ]


listlayout : M.Model -> Html M.Msg
listlayout model =
    div [ BH.classList [ B.columns, B.isCentered ] ]
        [ div [ BH.classList [ B.column, B.is11 ] ]
            [ newslist model
            ]
        ]


newslist : M.Model -> Html M.Msg
newslist model =
    let
        header =
            thead []
                [ tr
                    []
                    [ th [] [ text "日期" ]
                    , th [] [ text "标题" ]
                    , th [] [ text "阅读量" ]
                    ]
                ]

        body =
            let
                clickbtn d =
                    if d.clicking then
                        button
                            [ BH.classList [ B.button, B.isFullwidth, B.isDanger ]
                            , disabled d.clicking -- TODO 忽略本按钮的所有点击事件
                            ]
                            [ text "点击中" ]

                    else
                        button
                            [ BH.classList [ B.button, B.isFullwidth, B.isInfo, B.isOutlined ] --, B.isSmall ]
                            , onClick (M.Clicked d.acid d.clicking)
                            ]
                            [ text (String.fromInt d.news.click) ]

                row d =
                    tr
                        []
                        [ td [] [ text d.news.date ]
                        , td [] [ text d.news.title ]
                        , td [] [ clickbtn d ]
                        ]
            in
            tbody [] (List.map row model.news)
    in
    table
        [ BH.classList [ B.table, B.isStriped, B.isHoverable, B.isFullwidth, "has-sticky-header" ]
        ]
        [ header
        , body
        ]
