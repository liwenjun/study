module Model exposing (Click, Model, Msg(..), Record, decoder, decoderC, init, record2News, setClicking, updateElement)

import Json.Decode as D
import Json.Encode as E



-- MODEL


type alias Model =
    { news : List NewsRow
    }


init : E.Value -> Model
init _ =
    { news = [] }



-- MSG


type Msg
    = GetNews
    | RecvNews E.Value
    | Clicked Int Bool
    | RecvClick E.Value



-- DATA


type alias NewsRow =
    { acid : Int
    , clicking : Bool
    , news : Record
    }


record2News : Record -> NewsRow
record2News rec =
    { acid = rec.acid, clicking = False, news = rec }


type alias Record =
    { title : String
    , url : String
    , date : String
    , acid : Int
    , click : Int
    }


type alias Click =
    { acid : Int
    , click : Int
    }


initClick : Click
initClick =
    { acid = 0, click = 0 }


decoderRecord : D.Decoder Record
decoderRecord =
    D.map5 Record
        (D.field "title" D.string)
        (D.field "url" D.string)
        (D.field "date" D.string)
        (D.field "acid" D.int)
        (D.field "click" D.int)


decoderClick : D.Decoder Click
decoderClick =
    D.map2 Click
        (D.field "acid" D.int)
        (D.field "click" D.int)


decoderListRecord : D.Decoder (List Record)
decoderListRecord =
    D.list decoderRecord


decoder : E.Value -> List Record
decoder v =
    case D.decodeValue decoderListRecord v of
        Ok d ->
            d

        Err _ ->
            []


decoderC : E.Value -> Click
decoderC v =
    case D.decodeValue decoderClick v of
        Ok d ->
            d

        Err _ ->
            initClick


updateElement : List NewsRow -> Click -> List NewsRow
updateElement list click =
    let
        upset rec =
            if click.acid == rec.acid then
                let
                    rn =
                        rec.news
                in
                { rec | clicking = False, news = { rn | click = click.click } }

            else
                rec
    in
    List.map upset list


setClicking : List NewsRow -> Int -> List NewsRow
setClicking list acid =
    let
        upset rec =
            if acid == rec.acid then
                { rec | clicking = True }

            else
                rec
    in
    List.map upset list
