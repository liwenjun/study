module Components.Chat.Msg exposing (Msg(..), MsgsViewEvent(..))

{-| -}

import Browser.Dom as Dom
import ChatApi exposing (Guild, Member, Message)
import Components.Chat.Model exposing (Model)
import Json.Encode
import Jsonrpc exposing (RpcData)


{-| -}
type Msg
    = UpdateModel Model
    | ClickSendMessage String
    | ClickSendPersistentMessage String
    | ClickSelectedGuild String
    | ClickSelectedMember Member
    | ClickSelectOtherGuild
    | OnGetGuilds (RpcData (List Guild))
    | ClickJoinGuild String
    | OnJoinGuild (RpcData Member)
      ---
    | HandleMessage (RpcData Message)
      ---
    | OnFinishNameChange Bool
    | OnChangeName (RpcData String)
      ---
    | OnRecieveWsmessage Json.Encode.Value
      ---
    | OnMsgsViewEvent MsgsViewEvent
      ---
    | SetInputFocused
      ---
    | ClickLeaveGuild String
    | HandleLeaveGuild (RpcData Guild)
      ---
    | ClickCreateGuild
    | OnCreateGuild (RpcData Guild)
    | OnFinishCreateGuild Bool
    | SetRenderMarkdown Bool
    | NoOP


{-| -}
type MsgsViewEvent
    = TriedSnapScroll (Result Dom.Error ())
    | OnManualScrolled
    | GotViewport (Result Dom.Error Dom.Viewport)
