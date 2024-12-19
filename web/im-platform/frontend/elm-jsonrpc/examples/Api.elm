module Api exposing (..)

{-| 调用 `Chat Rest API`

@docs toUserFriendlyMessage, Token
@docs post, delete, get, patch

-}

import Json.Decode
import Json.Encode
import Jsonrpc


{-| -}
url : String
url =
    "http://127.0.0.1:8080/api"


{-| -}
type alias Token =
    { user_id : String
    , token : String
    }


{-| -}
decoderToken : Json.Decode.Decoder Token
decoderToken =
    Json.Decode.map2 Token
        (Json.Decode.field "user_id" Json.Decode.string)
        (Json.Decode.field "token" Json.Decode.string)


signin :
    { a
        | url : String
        , token : Maybe String
        , params : { b | username : String, password : String }
        , handler : Jsonrpc.RpcData Token -> msg
    }
    -> Cmd msg
signin opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = opts.token
            , method = "users.auth"
            , params =
                Json.Encode.object
                    [ ( "username", Json.Encode.string opts.params.username )
                    , ( "password", Json.Encode.string opts.params.password )
                    ]
            }
    in
    Jsonrpc.call param decoderToken opts.handler
