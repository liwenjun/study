module ChatApi exposing (..)

{-|

@docs User, UserStatus, decoderUser
@docs Token, decoderToken
@docs Guild, decoderGuild
@docs Member, decoderMember
@docs Message, decoderMessage
@docs Author, decoderAuthor
@docs Presence, decoderPresence
@docs ReadyEvent, decoderReadyEvent
@docs GuildCreateEvent, decoderGuildCreateEvent
@docs WebsocketMessage, CloseFrame, decoderWebsocketMessage, decoderWebsocketMessageValue
@docs WebsocketEvent, deocderWebsocketEvent

-}

import Json.Decode
import Json.Encode


{-| -}
type alias Token =
    { user_id : String
    , token : String
    }


decoderToken : Json.Decode.Decoder Token
decoderToken =
    Json.Decode.map2 Token
        (Json.Decode.field "user_id" Json.Decode.string)
        (Json.Decode.field "token" Json.Decode.string)


{-| -}
type UserStatus
    = Online -- The user is idle or away from the keyboard.
    | Away -- The user is busy. Clients should try to disable notifications in this state.
    | Busy -- The user is offline or invisible.
    | Offline


decoderUserStatus : String -> Json.Decode.Decoder UserStatus
decoderUserStatus t =
    case t of
        "ONLINE" ->
            Json.Decode.succeed Online

        "AWAY" ->
            Json.Decode.succeed Away

        "BUSY" ->
            Json.Decode.succeed Busy

        _ ->
            Json.Decode.succeed Offline


{-| -}
type alias User =
    { id : String
    , username : String
    , displayName : String
    , presence : Maybe UserStatus -- String
    }


{-| -}
decoderUser : Json.Decode.Decoder User
decoderUser =
    Json.Decode.map4 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.field "display_name" Json.Decode.string)
        (Json.Decode.field "presence"
            (Json.Decode.maybe (Json.Decode.string |> Json.Decode.andThen decoderUserStatus))
        )


{-| -}
type alias Guild =
    { id : String
    , name : String
    , ownerId : String
    }


{-| -}
decoderGuild : Json.Decode.Decoder Guild
decoderGuild =
    Json.Decode.map3 Guild
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "owner_id" Json.Decode.string)


{-| -}
type alias Member =
    { guildId : String
    , joinedAt : Int
    , user : User
    }


{-| -}
decoderMember : Json.Decode.Decoder Member
decoderMember =
    Json.Decode.map3 Member
        (Json.Decode.field "guild_id" Json.Decode.string)
        (Json.Decode.field "joined_at" Json.Decode.int)
        (Json.Decode.field "user" decoderUser)


{-| -}
type Author
    = AUser User
    | AMember Member


{-| -}
decoderAuthor : Json.Decode.Decoder Author
decoderAuthor =
    Json.Decode.oneOf
        [ decoderMember |> Json.Decode.map AMember
        , decoderUser |> Json.Decode.map AUser
        ]


{-| -}
type alias Message =
    { id : String
    , guildId : String
    , author : Author
    , content : String
    , nonce : Maybe String
    }


{-| -}
decoderMessage : Json.Decode.Decoder Message
decoderMessage =
    Json.Decode.map5 Message
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "guild_id" Json.Decode.string)
        (Json.Decode.field "author" decoderAuthor)
        (Json.Decode.field "content" Json.Decode.string)
        (Json.Decode.field "nonce" (Json.Decode.maybe Json.Decode.string))


{-| -}
type alias Presence =
    { userId : String
    , presence : UserStatus
    }


{-| -}
decoderPresence : Json.Decode.Decoder Presence
decoderPresence =
    Json.Decode.map2 Presence
        (Json.Decode.field "user_id" Json.Decode.string)
        (Json.Decode.field "presence"
            (Json.Decode.string |> Json.Decode.andThen decoderUserStatus)
        )


{-| -}
type alias ReadyEvent =
    { user : User, guilds : List Guild }


{-| -}
decoderReadyEvent : Json.Decode.Decoder ReadyEvent
decoderReadyEvent =
    Json.Decode.map2 ReadyEvent
        (Json.Decode.field "user" decoderUser)
        (Json.Decode.field "guilds" (Json.Decode.list decoderGuild))


{-| -}
type alias GuildCreateEvent =
    { guild : Guild, members : List Member }


{-| -}
decoderGuildCreateEvent : Json.Decode.Decoder GuildCreateEvent
decoderGuildCreateEvent =
    Json.Decode.map2 GuildCreateEvent
        (Json.Decode.field "guild" decoderGuild)
        (Json.Decode.field "members" (Json.Decode.list decoderMember))


{-| Websocket 消息定义
-}
type WebsocketMessage
    = Text WebsocketEvent
    | Binary (List Int)
    | Ping (List Int)
    | Pong (List Int)
    | Close CloseFrame
    | None


{-| -}
type alias CloseFrame =
    { code : Int, reason : WebsocketEvent }


{-| -}
decoderWebsocketMessageValue : Json.Encode.Value -> WebsocketMessage
decoderWebsocketMessageValue v =
    case Json.Decode.decodeValue decoderWebsocketMessage v of
        Ok d ->
            d

        Err _ ->
            None


{-| -}
decoderWebsocketMessage : Json.Decode.Decoder WebsocketMessage
decoderWebsocketMessage =
    Json.Decode.field "type" Json.Decode.string
        |> Json.Decode.andThen
            (\t ->
                case String.toLower t of
                    "message" ->
                        Json.Decode.map Text <| Json.Decode.field "data" decoderWebsocketEvent

                    "text" ->
                        -- for tauri websocket plugin
                        Json.Decode.map Text <| Json.Decode.field "data" decoderWebsocketEvent

                    "binary" ->
                        Json.Decode.map Binary <| Json.Decode.field "data" (Json.Decode.list Json.Decode.int)

                    "ping" ->
                        Json.Decode.map Ping <| Json.Decode.field "data" (Json.Decode.list Json.Decode.int)

                    "pong" ->
                        Json.Decode.map Pong <| Json.Decode.field "data" (Json.Decode.list Json.Decode.int)

                    "close" ->
                        Json.Decode.map Close <|
                            Json.Decode.map2 CloseFrame
                                (Json.Decode.field "code" Json.Decode.int)
                                (Json.Decode.field "reason" decoderWebsocketEvent)

                    _ ->
                        Json.Decode.succeed None
            )


{-| Websocket 事件定义
-}
type WebsocketEvent
    = Ready ReadyEvent
    | GuildCreate GuildCreateEvent
    | GuildRemove Guild
    | MessageCreate Message
    | MemberCreate Member
    | PresenceUpdate Presence
    | Other String Json.Encode.Value


{-| -}
decoderWebsocketEvent : Json.Decode.Decoder WebsocketEvent
decoderWebsocketEvent =
    Json.Decode.field "event" Json.Decode.string
        |> Json.Decode.andThen
            (\t ->
                case t of
                    "READY" ->
                        Json.Decode.map Ready
                            (Json.Decode.field "data" decoderReadyEvent)

                    "GUILD_CREATE" ->
                        Json.Decode.map GuildCreate
                            (Json.Decode.field "data" decoderGuildCreateEvent)

                    "GUILD_REMOVE" ->
                        Json.Decode.map GuildRemove
                            (Json.Decode.field "data" decoderGuild)

                    "MESSAGE_CREATE" ->
                        Json.Decode.map MessageCreate
                            (Json.Decode.field "data" decoderMessage)

                    "MEMBER_CREATE" ->
                        Json.Decode.map MemberCreate
                            (Json.Decode.field "data" decoderMember)

                    "PRESENCE_UPDATE" ->
                        Json.Decode.map PresenceUpdate
                            (Json.Decode.field "data" decoderPresence)

                    _ ->
                        Json.Decode.map2 Other
                            (Json.Decode.field "event" Json.Decode.string)
                            (Json.Decode.field "data" Json.Decode.value)
            )
