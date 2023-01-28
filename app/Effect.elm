port module Effect exposing (Effect(..), batch, fromCmd, loaded, map, none, perform)

import Browser.Navigation
import Form.FormData exposing (FormData)
import Http
import Pages.Fetcher
import SetRenderer exposing (SetList)
import Url exposing (Url)


type Effect msg
    = None
    | Cmd (Cmd msg)
    | Batch (List (Effect msg))
    | SetField { formId : String, name : String, value : String }
    | FetchRouteData
        { data : Maybe FormData
        , toMsg : Result Http.Error Url -> msg
        }
    | Submit
        { values : FormData
        , toMsg : Result Http.Error Url -> msg
        }
    | SubmitFetcher (Pages.Fetcher.Fetcher msg)
    | ELoaded SetList


loaded : SetList -> Effect msg
loaded setList =
    ELoaded setList


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

        FetchRouteData fetchInfo ->
            FetchRouteData
                { data = fetchInfo.data
                , toMsg = fetchInfo.toMsg >> fn
                }

        ELoaded setList ->
            ELoaded setList

        Submit fetchInfo ->
            Submit
                { values = fetchInfo.values
                , toMsg = fetchInfo.toMsg >> fn
                }

        SetField info ->
            SetField info

        SubmitFetcher fetcher ->
            fetcher
                |> Pages.Fetcher.map fn
                |> SubmitFetcher


perform :
    { fetchRouteData :
        { data : Maybe FormData
        , toMsg : Result Http.Error Url -> pageMsg
        }
        -> Cmd msg
    , submit :
        { values : FormData
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
perform ({ fromPageMsg, key } as helpers) effect =
    case effect of
        None ->
            Cmd.none

        Cmd cmd ->
            Cmd.map fromPageMsg cmd

        SetField info ->
            helpers.setField info

        Batch list ->
            Cmd.batch (List.map (perform helpers) list)

        FetchRouteData fetchInfo ->
            helpers.fetchRouteData
                fetchInfo

        Submit record ->
            helpers.submit record

        SubmitFetcher record ->
            helpers.runFetcher record

        ELoaded setList ->
            amplitude setList


port amplitude : SetRenderer.SetList -> Cmd msg


port environmentVariable : String -> Cmd msg
