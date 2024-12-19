module Components.Chat.View.UserInfoPanel exposing (view)

import Auth
import Components.Chat.Model exposing (..)
import Components.Chat.Msg exposing (..)
import Html exposing (Html)
import Shared
import W.Button
import W.Container
import W.InputField
import W.InputText
import W.Modal
import W.Text



-- VIEW


{-| -}
view : Auth.User -> Shared.Model -> Model -> Html Msg
view user shared model =
    [ W.Text.view
        [ W.Text.aux ]
        [ Html.text ("💖" ++ user.user.displayName) ]
    , W.Modal.view [ W.Modal.absolute, W.Modal.noBlur ]
        { isOpen = model.nameChangeStatus /= NotChanging
        , onClose = Nothing
        , content = [ dialogContent model ]
        }
    , [ W.Button.view
            [ W.Button.small
            ]
            { label = [ Html.text "改名" ]
            , onClick = UpdateModel { model | nameChangeStatus = ChangingTo "" }
            }
      ]
        |> W.Container.view [ W.Container.alignRight, W.Container.fill, W.Container.padRight_4 ]
    ]
        |> W.Container.view
            [ W.Container.fill
            , W.Container.padTop_4
            , W.Container.horizontal
            ]


dialogContent : Model -> Html Msg
dialogContent model =
    let
        str =
            case model.nameChangeStatus of
                NotChanging ->
                    ""

                ChangingTo new ->
                    new
    in
    [ W.Text.view [ W.Text.large ] [ Html.text "请输入实名" ]
    , W.InputField.view []
        { label = [ Html.text "新名称下次登录生效。" ]
        , input =
            [ W.InputText.view
                []
                { value = str
                , onInput = \new -> UpdateModel { model | nameChangeStatus = ChangingTo new }
                }
            ]
        }
    , [ W.Button.view
            [ W.Button.small
            ]
            { label = [ Html.text "确认" ]
            , onClick = OnFinishNameChange True
            }
      , W.Button.view
            [ W.Button.small
            ]
            { label = [ Html.text "取消" ]
            , onClick = OnFinishNameChange False
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
