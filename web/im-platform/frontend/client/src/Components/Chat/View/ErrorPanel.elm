module Components.Chat.View.ErrorPanel exposing (view)

{-| -}

import Auth
import Components.Chat.Model exposing (..)
import Components.Chat.Msg exposing (..)
import Html exposing (Html)
import Shared



-- VIEW


{-| -}
view : Auth.User -> Shared.Model -> Model -> Html Msg
view user shared model =
    Html.text "数据出问题了，请选择其他群组试试！"
