port module Ports exposing (..)

{-|

@docs callConnectWsserver, callDisconnectWsserver, subWsserverState, callSendWsmessage, subRecvWsmessage

-}

import Json.Encode



-- PORT


{-| 发送连接 Websocket Server 指令
-}
port callConnectWsserver : { url : String, data : Json.Encode.Value } -> Cmd msg


{-| 发送断开 Websocket Server 指令
-}
port callDisconnectWsserver : () -> Cmd msg


{-| 订阅 Websocket Server 连接状态变化消息
-}
port subWsserverState : (Bool -> msg) -> Sub msg


{-| 发送 Websocket 消息
-}
port callSendWsmessage : Json.Encode.Value -> Cmd msg


{-| 订阅 Websocket 接收到的消息
-}
port subRecvWsmessage : (Json.Encode.Value -> msg) -> Sub msg


{-| 发送本地存储指令
-}
port sendToLocalStorage : { key : String, value : Json.Encode.Value } -> Cmd msg
