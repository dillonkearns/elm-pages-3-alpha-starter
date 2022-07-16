module Effect exposing (Effect(..), batch, fromCmd, map, none, perform)

import Browser.Navigation
import FormDecoder
import Http
import Json.Decode as Decode
import Pages.Fetcher
import Task
import Time
import Url exposing (Url)


type Effect msg
    = None
    | Cmd (Cmd msg)
    | Batch (List (Effect msg))
    | GetStargazers (Result Http.Error Int -> msg)
    | FetchRouteData
        { data : Maybe FormDecoder.FormData
        , toMsg : Result Http.Error Url -> msg
        }
    | GetTheTime (Time.Posix -> msg)


type alias RequestInfo =
    { contentType : String
    , body : String
    }


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch =
    Batch


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


map : (a -> b) -> Effect a -> Effect b
map fn effect =
    case effect of
        None ->
            None

        Cmd cmd ->
            Cmd (Cmd.map fn cmd)

        Batch list ->
            Batch (List.map (map fn) list)

        GetStargazers toMsg ->
            GetStargazers (toMsg >> fn)

        FetchRouteData fetchInfo ->
            FetchRouteData
                { data = fetchInfo.data
                , toMsg = fetchInfo.toMsg >> fn
                }

        GetTheTime toMsg ->
            GetTheTime (toMsg >> fn)


perform :
    { fetchRouteData :
        { data : Maybe FormDecoder.FormData
        , toMsg : Result Http.Error Url -> pageMsg
        }
        -> Cmd msg
    , submit :
        { values : FormDecoder.FormData
        , toMsg : Result Http.Error Url -> pageMsg
        }
        -> Cmd msg
    , runFetcher :
        Pages.Fetcher.Fetcher pageMsg
        -> Cmd msg
    , fromPageMsg : pageMsg -> msg
    , key : Browser.Navigation.Key
    , setField : { formId : String, name : String, value : String } -> Cmd msg
    }
    -> Effect pageMsg
    -> Cmd msg
perform ({ fetchRouteData, fromPageMsg } as info) effect =
    case effect of
        None ->
            Cmd.none

        Cmd cmd ->
            Cmd.map fromPageMsg cmd

        Batch list ->
            Cmd.batch (List.map (perform info) list)

        GetStargazers toMsg ->
            Http.get
                { url = "https://api.github.com/repos/dillonkearns/elm-pages"
                , expect = Http.expectJson (toMsg >> fromPageMsg) (Decode.field "stargazers_count" Decode.int)
                }

        FetchRouteData fetchInfo ->
            info.fetchRouteData fetchInfo

        GetTheTime toMsg ->
            let
                _ =
                    Debug.log "Si consultó pues" "*!*!*!"
            in
            Task.perform
                (toMsg >> fromPageMsg)
                Time.now
