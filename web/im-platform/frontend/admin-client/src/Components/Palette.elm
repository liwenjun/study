module Components.Palette exposing (Palette, defaultPalette)

{-| -}

import Components.Colors as Colors
import Element exposing (Color, rgb255)
import Element.HexColor exposing (rgbCSSHex)


{-| -}
type alias Palette =
    { background : Color
    , foreground : Color
    , button :
        { normal : Color
        , hover : Color
        , focused : Color
        , down : Color
        }
    }

{-| -}
defaultPalette : Palette
defaultPalette =
    { background = Colors.neutral_800
    , foreground = Colors.amber_100
    , button =
        { normal = rgb255 76 175 80
        , hover = rgb255 92 207 96
        , focused = rgb255 92 207 96
        , down = rgb255 60 159 64
        }
    }
