module Components.Style exposing (..)

{-| -}

import Components.Dialog as Dialog
import Components.Palette exposing (Palette, defaultPalette)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Components.Colors as Colors


{-| -}
style =
    { button = button defaultPalette
    , smallButton = smallButton defaultPalette
    , background = background defaultPalette
    , textButton = textButton defaultPalette
    , textInput = textInput defaultPalette
    , text = text defaultPalette
    }


{-| -}
background : Palette -> Element.Attribute msg
background palette =
    Background.color palette.background


{-| -}
text : Palette -> Int -> List (Attribute msg)
text palette size =
    [ --, Font.family [ Font.typeface "Georgia", Font.serif ]
      Font.size size

    --, Font.color palette.foreground
    ]


{-| -}
button : Palette -> List (Attribute msg)
button palette =
    [ padding 7
    , Border.rounded 5
    , Background.color palette.button.normal
    , Font.color palette.foreground

    --, Font.family [ Font.typeface "Georgia", Font.serif ]
    , mouseDown [ Background.color palette.button.down ]
    , mouseOver [ Background.color palette.button.hover ]
    , focused [ Background.color palette.button.focused ]
    ]


{-| -}
smallButton : Palette -> List (Attribute msg)
smallButton palette =
    [ padding 5
    , Border.rounded 3
    , Background.color palette.button.normal
    , Font.color palette.foreground
    , Font.size 14
    , mouseDown [ Background.color palette.button.down ]
    , mouseOver [ Background.color palette.button.hover ]
    , focused [ Background.color palette.button.focused ]
    ]


{-| -}
textButton : Palette -> List (Attribute msg)
textButton palette =
    [ paddingXY 7 1
    , mouseDown [ Background.color palette.button.down ]
    , mouseOver [ Background.color palette.button.hover ]
    , focused [ Background.color palette.button.focused ]
    ]


{-| -}
textInput : Palette -> List (Attribute msg)
textInput palette =
    [ padding 7
    , Border.rounded 5

    --, Background.color palette.foreground
    , Font.color palette.background

    --, Font.family [ Font.typeface "Georgia", Font.serif ]
    ]


{-| -}
dialogConfig :
    { closeMessage : Maybe msg
    , header : Maybe (Element msg)
    , body : Maybe (Element msg)
    , footer : Maybe (Element msg)
    }
    -> Dialog.Config msg
dialogConfig opts =
    { closeMessage = opts.closeMessage
    , maskAttributes = []
    , containerAttributes =
        [ Border.rounded 5
        , Background.color (rgb 1 1 1)
        , centerX
        , centerY
        , padding 10
        , spacing 20
        , width (px 400)
        ]
    , headerAttributes = [ Font.size 24, padding 5 ]
    , bodyAttributes = [ padding 20 ]
    , footerAttributes = []
    , header = opts.header
    , body = opts.body
    , footer = opts.footer
    }



{-
guildStyle =
    [ width fill
    , paddingXY 2 5
    , mouseDown [ Background.color <| rgb255 0x40 0x80 0x40 ]
    , mouseOver [ Background.color <| rgb255 0x80 0xC0 0x80 ]
    , focused [ Background.color <| rgb255 0xC0 0xC0 0x40 ]
    --, onClick <| ClickSelectedGuild x.guild.id
    ]
        ++ (if x.guild.id == model.selectedGuild then
                [ Background.color <| rgb255 0xB0 0xE0 0xE0 ]

            else
                []
           )
-}