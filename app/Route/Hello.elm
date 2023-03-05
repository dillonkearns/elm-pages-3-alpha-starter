module Route.Hello exposing (ActionData, Data, Model, Msg(..), RouteParams, action, data, route)

import BackendTask
import BackendTask.Http
import Effect
import ErrorPage
import FatalError
import Head
import Html
import Json.Decode as Decode
import Platform.Sub
import RouteBuilder exposing (App)
import Server.Request
import Server.Response
import Shared
import View


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    {}


route =
    RouteBuilder.serverRender { data = data, action = action, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , subscriptions = subscriptions
            , update = update
            , init = init
            }


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( {}, Effect.Effect msg )
init app sharedModel =
    ( {}, Effect.none )


update :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect msg )
update app shared msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )


subscriptions :
    routeParams
    -> path
    -> sharedModel
    -> model
    -> Sub msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    { stars : Int
    }


type alias ActionData =
    {}


data :
    RouteParams
    -> Server.Request.Parser (BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage))
data routeParams =
    Server.Request.succeed
        (BackendTask.Http.getWithOptions
            { url = "https://api.github.com/repos/dillonkearns/elm-pages"
            , expect = BackendTask.Http.expectJson (Decode.field "stargazers_count" Decode.int)
            , headers = []
            , cacheStrategy = Just BackendTask.Http.IgnoreCache
            , retries = Nothing
            , timeoutInMs = Nothing
            , cachePath = Nothing
            }
            |> BackendTask.allowFatal
            |> BackendTask.map
                (\stars -> Server.Response.render { stars = stars })
        )


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View msg
view app shared model =
    { title = "Hello", body = [ Html.text (String.fromInt app.data.stars) ] }


action :
    RouteParams
    -> Server.Request.Parser (BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage))
action routeParams =
    Server.Request.succeed (BackendTask.succeed (Server.Response.render {}))
