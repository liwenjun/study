module Utils exposing
    ( onCtrlEnter, onEnter, onEnterAny, onShiftEnter
    , hasManualScrolledUp, onScroll
    , setFocus
    , datetime, datetimeUtc
    )

{-|

@docs onCtrlEnter, onEnter, onEnterAny, onShiftEnter
@docs hasManualScrolledUp, onScroll
@docs setFocus
@docs datetime, datetimeUtc

-}

import Browser.Dom as Dom
import Effect exposing (Effect)
import Element
import Html.Events
import Iso8601
import Json.Decode as Decode
import Task
import Time


{-| -}
onScroll : msg -> Element.Attribute msg
onScroll msg =
    Element.htmlAttribute <|
        Html.Events.on "scroll" <|
            Decode.succeed msg


{-| -}
onEnterAny : msg -> Element.Attribute msg
onEnterAny msg =
    Element.htmlAttribute <|
        Html.Events.on "keyup"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the enter key"
                    )
            )


{-| -}
onEnter : msg -> Element.Attribute msg
onEnter msg =
    Element.htmlAttribute <|
        Html.Events.on "keyup"
            (Decode.map2 Tuple.pair
                (Decode.at [ "keyCode" ] Decode.int)
                (Decode.at [ "shiftKey" ] Decode.bool)
                |> Decode.andThen
                    (\( key, shift ) ->
                        if not shift && (key == 13) then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the shift+enter key"
                    )
            )


{-| -}
onShiftEnter : msg -> Element.Attribute msg
onShiftEnter msg =
    Element.htmlAttribute <|
        Html.Events.on "keyup"
            (Decode.map2 Tuple.pair
                (Decode.at [ "keyCode" ] Decode.int)
                (Decode.at [ "shiftKey" ] Decode.bool)
                |> Decode.andThen
                    (\( key, shift ) ->
                        if shift && (key == 13) then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the shift+enter key"
                    )
            )


{-| -}
onCtrlEnter : msg -> Element.Attribute msg
onCtrlEnter msg =
    Element.htmlAttribute <|
        Html.Events.on "keyup"
            (Decode.map2 Tuple.pair
                (Decode.at [ "keyCode" ] Decode.int)
                (Decode.at [ "ctrlKey" ] Decode.bool)
                |> Decode.andThen
                    (\( key, ctrl ) ->
                        if ctrl && (key == 13) then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the ctrl+enter key"
                    )
            )


{-| -}
hasManualScrolledUp : Dom.Viewport -> Bool
hasManualScrolledUp =
    hasManualScrolledUp_ autoScrollMargin


{-| -}
hasManualScrolledUp_ : Float -> Dom.Viewport -> Bool
hasManualScrolledUp_ margin viewport =
    viewport.viewport.y
        + viewport.viewport.height
        + margin
        < viewport.scene.height


{-| If user hasn't manually scrolled up more than this value,
then allow auto scrolling when new chat messages come in.

Tested with Main's logViewport. One scroll wheel was 53.

This is also good for floating point comparison.

-}
autoScrollMargin : Float
autoScrollMargin =
    30


{-| -}
setFocus : String -> msg -> Effect msg
setFocus id m =
    Task.attempt (\_ -> m) (Dom.focus id)
        |> Effect.sendCmd


{-|

```
Utils.datetime "67446874886262785"
"2023-07-06 10:49:48" : String
```

-}
datetime : String -> String
datetime =
    datetimeUtc 8
        >> Maybe.withDefault ""
        >> String.left 19
        >> String.replace "T" " "


{-|

```
Utils.datetimeUtc 0 "67446874886262785"
Just "2023-07-06T02:49:48.075Z" : Maybe String
```

-}
datetimeUtc : Float -> String -> Maybe String
datetimeUtc utc id =
    id
        |> String.toFloat
        |> Maybe.map
            (\x ->
                x
                    / (2 ^ 22)
                    -- epoch 2023-01-01 00:00:00
                    |> (+) 1672531200000
                    |> (+) (60 * 60 * 1000 * utc)
                    |> floor
                    |> Time.millisToPosix
                    |> Iso8601.fromTime
            )
