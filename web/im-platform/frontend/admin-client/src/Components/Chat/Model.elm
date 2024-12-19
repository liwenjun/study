module Components.Chat.Model exposing (ChatGuild, ChatMode(..), Model, NameChangeStatus(..), initModel)

{-| -}

import BoundedList exposing (BoundedList)
import ChatApi exposing (Guild, Member, Message)
import Shared.Msg exposing (Msg(..))
import ChatApi exposing (WebsocketEvent, WebsocketMessage)


{-| -}
type ChatMode
    = JoinOrCreateGuild
    | ChatInGuild String


{-| -}
type alias ChatGuild =
    { guild : Guild
    , members : List Member
    , messages : BoundedList Message -- List Message
    }


{-| -}
type alias Model =
    { input : String
    , guilds : List ChatGuild
    , chatMode : ChatMode
    , selectedGuild : String
    , sendMember : Maybe Member
    , otherGuilds : List Guild

    ---
    , nameChangeStatus : NameChangeStatus
    , hasManualScrolledUp : Bool

    ---
    , canCreateGuild : Bool
    , guildName : String
    , renderMarkdown : Bool
    ---
    , msgs: List WebsocketMessage
    }


{-| -}
initModel : Model
initModel =
    { input = "点这里发送消息！"
    , guilds = []
    , chatMode = JoinOrCreateGuild
    , selectedGuild = ""
    , sendMember = Nothing
    , otherGuilds = []

    ---
    , nameChangeStatus = NotChanging
    , hasManualScrolledUp = False

    ---
    , canCreateGuild = False
    , guildName = ""
    , renderMarkdown = True

    ---
    , msgs = []
    }


{-| -}
type NameChangeStatus
    = NotChanging
    | ChangingTo String
