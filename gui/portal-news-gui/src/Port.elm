port module Port exposing (..)

import Json.Encode as E



{- 新闻列表 -}


port getNewsList : () -> Cmd msg


port newsReceiver : (E.Value -> msg) -> Sub msg



{- 点击新闻 -}


port sendClick : Int -> Cmd msg


port clickReceiver : (E.Value -> msg) -> Sub msg
