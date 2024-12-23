module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , closeWebsocketServer, openWebsocketServer, signIn, signOut
    , map, toCmd
    , clearUser, saveUser, saveGuild, sendWebsocketMessage
    , changeDisplayName
    )

{-|

@docs Effect
@docs none, batch
@docs sendCmd, sendMsg
@docs pushRoute, replaceRoute, loadExternalUrl

@docs closeWebsocketServer, openWebsocketServer, signIn, signOut
@docs map, toCmd
@docs clearUser, saveUser, saveGuild, sendWebsocketMessage
@docs changeDisplayName

-}

import Browser.Navigation
import Dict exposing (Dict, member)
import Json.Encode
import Ports
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg
import Task
import Url exposing (Url)


type Effect msg
    = -- BASICS
      None
    | Batch (List (Effect msg))
    | SendCmd (Cmd msg)
      -- ROUTING
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
      -- SHARED
    | SendSharedMsg Shared.Msg.Msg
      -- PORT
    | CallConnectWsserver { url : String, data : Json.Encode.Value }
    | CallDisconnectWsserver
    | CallSendWsmessage Json.Encode.Value
    | SendToLocalStorage { key : String, value : Json.Encode.Value }



-- SHARED


{-| -}
signIn : Shared.Model.User -> Effect msg
signIn token =
    SendSharedMsg (Shared.Msg.SignIn token)


{-| -}
signOut : Effect msg
signOut =
    SendSharedMsg Shared.Msg.SignOut


{-| -}
changeDisplayName : String -> Effect msg
changeDisplayName name =
    SendSharedMsg (Shared.Msg.ChangeDisplayName name)


{-| -}
saveUser : String -> Effect msg
saveUser token =
    SendToLocalStorage
        { key = "user"
        , value = Json.Encode.string token
        }


{-| -}
clearUser : Effect msg
clearUser =
    SendToLocalStorage
        { key = "user"
        , value = Json.Encode.null
        }


{-| -}
saveGuild : String -> Effect msg
saveGuild guild =
    SendToLocalStorage
        { key = "guild"
        , value = Json.Encode.string guild
        }


{-| -}
openWebsocketServer : { url : String, data : Json.Encode.Value } -> Effect msg
openWebsocketServer options =
    CallConnectWsserver options


{-| -}
closeWebsocketServer : Effect msg
closeWebsocketServer =
    batch
        [ CallDisconnectWsserver
        , SendSharedMsg (Shared.Msg.OnSetWsserverState False)
        ]


sendWebsocketMessage : { userId : String, guildId : String, message : String, memberId : Maybe String } -> Effect msg
sendWebsocketMessage options =
    CallSendWsmessage <|
        Json.Encode.object
            [ ( "user_id", Json.Encode.string options.userId )
            , ( "guild_id", Json.Encode.string options.guildId )
            , ( "content", Json.Encode.string options.message )
            , ( "nonce"
              , case options.memberId of
                    Just m ->
                        Json.Encode.string m

                    Nothing ->
                        Json.Encode.null
              )
            ]



-- BASICS


{-| Don't send any effect.
-}
none : Effect msg
none =
    None


{-| Send multiple effects at once.
-}
batch : List (Effect msg) -> Effect msg
batch =
    Batch


{-| Send a normal `Cmd msg` as an effect, something like `Http.get` or `Random.generate`.
-}
sendCmd : Cmd msg -> Effect msg
sendCmd =
    SendCmd


{-| Send a message as an effect. Useful when emitting events from UI components.
-}
sendMsg : msg -> Effect msg
sendMsg msg =
    Task.succeed msg
        |> Task.perform identity
        |> SendCmd



-- ROUTING


{-| Set the new route, and make the back button go back to the current route.
-}
pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
pushRoute route =
    PushUrl (Route.toString route)


{-| Set the new route, but replace the previous one, so clicking the back
button **won't** go back to the previous route.
-}
replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
replaceRoute route =
    ReplaceUrl (Route.toString route)


{-| Redirect users to a new URL, somewhere external your web application.
-}
loadExternalUrl : String -> Effect msg
loadExternalUrl =
    LoadExternalUrl



-- INTERNALS


{-| Elm Land depends on this function to connect pages and layouts
together into the overall app.
-}
map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        SendCmd cmd ->
            SendCmd (Cmd.map fn cmd)

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url

        SendSharedMsg sharedMsg ->
            SendSharedMsg sharedMsg

        CallConnectWsserver options ->
            CallConnectWsserver options

        CallDisconnectWsserver ->
            CallDisconnectWsserver

        CallSendWsmessage options ->
            CallSendWsmessage options

        SendToLocalStorage value ->
            SendToLocalStorage value


{-| Elm Land depends on this function to perform your effects.
-}
toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : Shared.Model.Model
    , fromSharedMsg : Shared.Msg.Msg -> msg
    , batch : List msg -> msg
    , toCmd : msg -> Cmd msg
    }
    -> Effect msg
    -> Cmd msg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        SendCmd cmd ->
            cmd

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        SendSharedMsg sharedMsg ->
            Task.succeed sharedMsg
                |> Task.perform options.fromSharedMsg

        CallConnectWsserver opt ->
            Ports.callConnectWsserver opt

        CallDisconnectWsserver ->
            Ports.callDisconnectWsserver ()

        CallSendWsmessage opt ->
            Ports.callSendWsmessage opt

        SendToLocalStorage value ->
            Ports.sendToLocalStorage value
