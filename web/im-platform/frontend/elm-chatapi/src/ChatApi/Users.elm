module ChatApi.Users exposing
    ( check, create, login, getSelf
    , getGuilds, getOtherGuilds, changeDisplayName
    )

{-| 用户创建、登录相关 api 调用

@docs check, create, login, getSelf
@docs getGuilds, getOtherGuilds, changeDisplayName

-}

import ChatApi exposing (..)
import Json.Decode
import Json.Encode
import Jsonrpc


{-| -}
login :
    { a
        | url : String
        , params : { b | username : String, password : String }
        , handler : Jsonrpc.RpcData Token -> msg
    }
    -> Cmd msg
login opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = Nothing
            , method = "users.auth"
            , params =
                Json.Encode.object
                    [ ( "username", Json.Encode.string opts.params.username )
                    , ( "password", Json.Encode.string opts.params.password )
                    ]
            }
    in
    Jsonrpc.call param decoderToken opts.handler


{-| -}
create :
    { a
        | url : String
        , params : { b | username : String, password : String }
        , handler : Jsonrpc.RpcData User -> msg
    }
    -> Cmd msg
create opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = Nothing
            , method = "users.create"
            , params =
                Json.Encode.object
                    [ ( "username", Json.Encode.string opts.params.username )
                    , ( "password", Json.Encode.string opts.params.password )
                    ]
            }
    in
    Jsonrpc.call param decoderUser opts.handler


{-| -}
check :
    { a
        | url : String
        , params : String
        , handler : Jsonrpc.RpcData Bool -> msg
    }
    -> Cmd msg
check opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = Nothing
            , method = "users.check"
            , params = Json.Encode.list Json.Encode.string (opts.params |> List.singleton)
            }
    in
    Jsonrpc.call param Json.Decode.bool opts.handler


{-| -}
getSelf :
    { a
        | url : String
        , token : Maybe String
        , handler : Jsonrpc.RpcData User -> msg
    }
    -> Cmd msg
getSelf opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = opts.token
            , method = "users.self"
            , params = Json.Encode.null
            }
    in
    Jsonrpc.call param decoderUser opts.handler


getGuilds :
    { a
        | url : String
        , token : Maybe String
        , handler : Jsonrpc.RpcData (List Guild) -> msg
    }
    -> Cmd msg
getGuilds opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = opts.token
            , method = "users.guilds"
            , params = Json.Encode.null
            }
    in
    Jsonrpc.call param (Json.Decode.list decoderGuild) opts.handler


getOtherGuilds :
    { a
        | url : String
        , token : Maybe String
        , handler : Jsonrpc.RpcData (List Guild) -> msg
    }
    -> Cmd msg
getOtherGuilds opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = opts.token
            , method = "users.other_guilds"
            , params = Json.Encode.null
            }
    in
    Jsonrpc.call param (Json.Decode.list decoderGuild) opts.handler


changeDisplayName :
    { a
        | url : String
        , token : Maybe String
        , params : String
        , handler : Jsonrpc.RpcData String -> msg
    }
    -> Cmd msg
changeDisplayName opts =
    let
        param : Jsonrpc.Param
        param =
            { url = opts.url
            , token = opts.token
            , method = "users.update_displayname"
            , params = Json.Encode.list Json.Encode.string (opts.params |> List.singleton)
            }
    in
    Jsonrpc.call param Json.Decode.string opts.handler
