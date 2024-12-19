module Shared.Model exposing (Model, User, defaultModel)

{-| 全局模型

@doc Model, Token, defaultModel

-}

import ChatApi as Api


{-| -}
type alias User =
    { user : Api.User
    , token : Api.Token
    }


{-| Normally, this value would live in "Shared.elm"
but that would lead to a circular dependency import cycle.

For that reason, both `Shared.Model` and `Shared.Msg` are in their
own file, so they can be imported by `Effect.elm`

-}
type alias Model =
    { baseUrl : String
    , wsServer : String
    , wsConnected : Bool
    , user : Maybe User
    , guild : Maybe String
    }


{-| -}
defaultModel : Model
defaultModel =
    { baseUrl = ""
    , wsServer = ""
    , wsConnected = False
    , user = Nothing
    , guild = Nothing
    }
