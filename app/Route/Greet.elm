module Route.Greet exposing (ActionData, Data, Model, Msg, route)

import DataSource exposing (DataSource)
import ErrorPage exposing (ErrorPage)
import Head
import Head.Seo as Seo
import Html
import Pages.Msg
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import RouteBuilder exposing (StatefulRoute, StatelessRoute, StaticPayload)
import Server.Request as Request
import Server.Response as Response exposing (Response)
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.serverRender
        { head = head
        , data = data
        , action = \_ -> Request.succeed (DataSource.fail "No action.")
        }
        |> RouteBuilder.buildNoState { view = view }


type alias Data =
    { name : Maybe String
    }


type alias ActionData =
    {}


data : RouteParams -> Request.Parser (DataSource (Response Data ErrorPage))
data routeParams =
    Request.oneOf
        [ Request.expectQueryParam "name"
            |> Request.map
                (\name ->
                    DataSource.succeed
                        (Response.render
                            { name = Just name }
                        )
                )
        , Request.succeed
            (DataSource.succeed
                (Response.render
                    { name = Nothing }
                )
            )
        ]


head :
    StaticPayload Data ActionData RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data ActionData RouteParams
    -> View (Pages.Msg.Msg Msg)
view maybeUrl sharedModel static =
    { title = "Greetings"
    , body =
        [ Html.div []
            [ case static.data.name of
                Just name ->
                    Html.text ("Hello " ++ name)

                Nothing ->
                    Html.text "Hello, I didn't find your name"
            ]
        ]
    }
