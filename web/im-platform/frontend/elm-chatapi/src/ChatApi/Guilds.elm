module ChatApi.Guilds exposing (create, join, leave, sendMessage)

{-| 创建群组相关 api 调用

@docs create, join, leave, sendMessage

-}

import ChatApi exposing (..)
import Json.Encode
import Jsonrpc


{-| 建群
-}
create :
    { a
        | url : String
        , token : Maybe String
        , params : { b | name : String }
        , handler : Jsonrpc.RpcData Guild -> msg
    }
    -> Cmd msg
create opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = opts.token
            , method = "guilds.create"
            , params =
                Json.Encode.object
                    [ ( "name", Json.Encode.string opts.params.name )
                    ]
            }
    in
    Jsonrpc.call param decoderGuild opts.handler


{-| 退群
-}
leave :
    { a
        | url : String
        , token : Maybe String
        , params : String
        , handler : Jsonrpc.RpcData Guild -> msg
    }
    -> Cmd msg
leave opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = opts.token
            , method = "guilds.leave"
            , params = Json.Encode.list Json.Encode.string (opts.params |> List.singleton)
            }
    in
    Jsonrpc.call param decoderGuild opts.handler


{-| 加群
-}
join :
    { a
        | url : String
        , token : Maybe String
        , params : String
        , handler : Jsonrpc.RpcData Member -> msg
    }
    -> Cmd msg
join opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = opts.token
            , method = "guilds.join"
            , params = Json.Encode.list Json.Encode.string (opts.params |> List.singleton)
            }
    in
    Jsonrpc.call param decoderMember opts.handler


{-| -}
sendMessage :
    { a
        | url : String
        , token : Maybe String
        , params : { b | guildId : String, content : String, nonce : Maybe String }
        , handler : Jsonrpc.RpcData Message -> msg
    }
    -> Cmd msg
sendMessage opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = opts.token
            , method = "guilds.message"
            , params =
                Json.Encode.object
                    [ ( "guild_id", Json.Encode.string opts.params.guildId )
                    , ( "content", Json.Encode.string opts.params.content )
                    , ( "nonce"
                      , case opts.params.nonce of
                            Nothing ->
                                Json.Encode.null

                            Just s ->
                                Json.Encode.string s
                      )
                    ]
            }
    in
    Jsonrpc.call param decoderMessage opts.handler
