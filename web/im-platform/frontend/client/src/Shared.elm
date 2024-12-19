module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Dict
import Effect exposing (Effect)
import Json.Decode
import Json.Encode
import Ports
import Route exposing (Route)
import Route.Path
import Shared.Model exposing (defaultModel)
import Shared.Msg



-- FLAGS


type alias Flags =
    { origin : String

    --, user : Maybe Json.Encode.Value
    , guild : Maybe String
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map2 Flags
        (Json.Decode.field "origin" Json.Decode.string)
        --(Json.Decode.field "user" Json.Decode.string)
        (Json.Decode.field "guild" (Json.Decode.nullable Json.Decode.string))



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    case flagsResult of
        Ok flag ->
            ( { defaultModel
                | baseUrl = flag.origin ++ "/api"
                , guild = flag.guild
                , wsServer = String.replace "http" "ws" flag.origin ++ "/gateway"
              }
            , Effect.none
            )

        _ ->
            ( defaultModel, Effect.none )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Shared.Msg.SignIn user ->
            ( { model | user = Just user }
            , Effect.batch
                [ Effect.pushRoute
                    { path = Route.Path.Chat
                    , query = Dict.empty
                    , hash = Nothing
                    }
                ]
            )

        Shared.Msg.SignOut ->
            ( { defaultModel | user = Nothing }
            , Effect.pushRoute
                { path = Route.Path.Home_
                , query = Dict.empty
                , hash = Nothing
                }
            )

        Shared.Msg.OnSetWsserverState state ->
            ( { model | wsConnected = state }, Effect.none )

        Shared.Msg.ChangeDisplayName name ->
            ( { model
                | user =
                    model.user
                        |> Maybe.map
                            (\x ->
                                let
                                    u =
                                        x.user

                                    nu =
                                        { u | displayName = name }
                                in
                                { x | user = nu }
                            )
              }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    --Sub.batch
    --    []
    Ports.subWsserverState Shared.Msg.OnSetWsserverState
