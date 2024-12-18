module Main exposing (main)

import Browser
import Html exposing (Html)
import Json.Encode as E
import Model as M exposing (Msg(..))
import Port exposing (clickReceiver, getNewsList, newsReceiver, sendClick)
import View as V



-- MAIN


main : Program E.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    M.Model


init : E.Value -> ( Model, Cmd Msg )
init flags =
    ( M.init flags
    , getNewsList ()
    )



-- UPDATE


type alias Msg =
    M.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetNews ->
            ( model
            , getNewsList ()
            )

        RecvNews message ->
            ( { model | news = List.map M.record2News (M.decoder message) }
            , Cmd.none
            )

        Clicked acid flag ->
            ( { model | news = M.setClicking model.news acid }
            , if flag then
                Cmd.none

              else
                sendClick acid
            )

        RecvClick message ->
            ( { model | news = M.updateElement model.news (M.decoderC message) }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ newsReceiver RecvNews
        , clickReceiver RecvClick
        ]



-- VIEW


view : Model -> Html Msg
view model =
    V.layout model
