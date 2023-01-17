module Route.Hello exposing (ActionData, Data, Model, Msg(..), RouteParams, action, data, route)

{-| -}

import BackendTask
import BackendTask.Http
import Effect
import ErrorPage
import FatalError
import Head
import Html
import Json.Decode as Decode
import Pages.PageUrl
import Platform.Sub
import RouteBuilder
import Server.Request
import Server.Response
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
    Maybe Pages.PageUrl.PageUrl
    -> sharedModel
    -> RouteBuilder.StaticPayload Data ActionData RouteParams
    -> ( {}, Effect.Effect msg )
init pageUrl sharedModel app =
    ( {}, Effect.none )


update :
    Pages.PageUrl.PageUrl
    -> sharedModel
    -> RouteBuilder.StaticPayload Data ActionData RouteParams
    -> Msg
    -> Model
    -> ( Model, Effect.Effect msg )
update pageUrl sharedModel app msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )


subscriptions :
    Maybe Pages.PageUrl.PageUrl
    -> routeParams
    -> path
    -> sharedModel
    -> model
    -> Sub msg
subscriptions maybePageUrl routeParams path sharedModel model =
    Platform.Sub.none


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


head : RouteBuilder.StaticPayload Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    Maybe Pages.PageUrl.PageUrl
    -> sharedModel
    -> Model
    -> RouteBuilder.StaticPayload Data ActionData RouteParams
    -> View.View msg
view maybeUrl sharedModel model app =
    { title = "Hello", body = [ Html.text (String.fromInt app.data.stars) ] }


action :
    RouteParams
    -> Server.Request.Parser (BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage))
action routeParams =
    Server.Request.succeed (BackendTask.succeed (Server.Response.render {}))
