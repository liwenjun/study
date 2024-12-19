module Jsonrpc exposing
    ( RpcError, RpcData, Param
    , call, toResult
    )

{-| 一个通用的JsonRpc-V2调用接口，帮助实现JsonRpc客户端应用。


# 数据结构


## JsonRpc 数据结构

@docs RpcError, RpcData, Param


## Cmd 方式调用

@docs call, toResult

-}

--import Json.Decode.Pipeline exposing (optional, required)

import Http exposing (Header, Response)
import Json.Decode
import Json.Encode
import RemoteData exposing (RemoteData(..), WebData)



-- 数据结构


{-| JsonRpc 返回错误格式定义
-}
type alias RpcError =
    { code : Int
    , message : String
    , data : Maybe String
    }


{-| -}
decoderRpcError : Json.Decode.Decoder RpcError
decoderRpcError =
    Json.Decode.map3 RpcError
        (Json.Decode.field "code" Json.Decode.int)
        (Json.Decode.field "message" Json.Decode.string)
        (Json.Decode.field "data" (Json.Decode.maybe Json.Decode.string))


{-| JsonRpc 响应结果
-}
type Response a
    = InnerResult a
    | InnerError RpcError


{-| -}
decoderResponse : Json.Decode.Decoder a -> Json.Decode.Decoder (Response a)
decoderResponse decoderA =
    Json.Decode.oneOf
        [ Json.Decode.map InnerResult (Json.Decode.at [ "result" ] decoderA)
        , Json.Decode.map InnerError (Json.Decode.at [ "error" ] decoderRpcError)
        ]


{-| 基于 http 的 JsonRpc 响应结果
-}
type alias RpcData a =
    WebData (Response a)


{-| Header for explicitly stating we are expecting JSON back.
-}
acceptJson : Header
acceptJson =
    Http.header "Accept" "application/json"



-- 调用函数


{-| 调用参数

TODO: 加约束，只支持对象或数组类型参数。

-}
type alias Param =
    { url : String
    , token : Maybe String
    , method : String
    , params : Json.Encode.Value
    }


{-| 构建JsonRpc请求体
-}
jsonrpc_request : Param -> Json.Encode.Value
jsonrpc_request opts =
    Json.Encode.object
        [ ( "id", Json.Encode.int 0 )
        , ( "jsonrpc", Json.Encode.string "2.0" )
        , ( "auth"
          , case opts.token of
                Just t ->
                    Json.Encode.string t

                Nothing ->
                    Json.Encode.null
          )
        , ( "method", Json.Encode.string opts.method )
        , ( "params", opts.params )
        ]


{-| HTTP 调用方法
-}
call :
    Param
    -> Json.Decode.Decoder a
    -> (RpcData a -> msg)
    -> Cmd msg
call opts decoder handler =
    Http.request
        { method = "POST"
        , headers = [ acceptJson ]
        , url = opts.url
        , body = Http.jsonBody (jsonrpc_request opts)
        , expect = Http.expectJson (RemoteData.fromResult >> handler) (decoderResponse decoder)
        , timeout = Nothing
        , tracker = Nothing
        }



-- 辅助函数


{-| 将平面化处理结果转换为Result
-}
toResult : RpcData a -> Result RpcError a
toResult data =
    let
        notRpcErr str =
            { code = -1
            , message = "非rpc错误"
            , data = Just str
            }
    in
    case data of
        Success d ->
            case d of
                InnerResult v ->
                    Ok v

                InnerError e ->
                    Err e

        Failure e ->
            Err (notRpcErr <| httpErrToString e)

        _ ->
            Err (notRpcErr "未调用后台")


{-| Http.Error转换为String
-}
httpErrToString : Http.Error -> String
httpErrToString he =
    case he of
        Http.BadUrl u ->
            "无效URL => " ++ u

        Http.Timeout ->
            "超时"

        Http.NetworkError ->
            "网络出错"

        Http.BadStatus status ->
            "返回状态码" ++ String.fromInt status

        Http.BadBody reason ->
            reason
