module Components.Chat.View.ErrorPanel exposing (view)

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
    column
        [ width fill
        , height fill
        , paddingEach { right = 10, left = 10, top = 10, bottom = 0 }
        ]
        [ text "数据出问题了，请选择其他群组试试！"
            |> el [ centerX, centerY ]
        ]
