module Route.Superset.Set_ exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Dphones.Enum.Order_by
import Dphones.InputObject
import Dphones.Query
import Effect
import ErrorPage exposing (ErrorPage)
import FatalError exposing (FatalError)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Hasura
import Head
import Head.Seo as Seo
import Pages.Msg
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import RouteBuilder exposing (StatefulRoute, StaticPayload)
import Server.Request as Request
import Server.Response as Response exposing (Response)
import SetRenderer
import Shared
import View exposing (View)


type alias Data =
    SetRenderer.SetList


type alias Model =
    Data


type Msg
    = NoOp


type alias RouteParams =
    { set : String }


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender
        { head = head
        , data = data
        , action = \_ -> Request.skip "No action."
        }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init =
                \_ _ staticPayload ->
                    ( staticPayload.data, Effect.loaded staticPayload.data )
            , update =
                \_ sharedModel static msg model ->
                    ( model, Effect.none )
            , subscriptions =
                \maybePageUrl routeParams path sharedModel model ->
                    Sub.none
            }


data : RouteParams -> Request.Parser (BackendTask FatalError (Response Data ErrorPage))
data routeParams =
    let
        mixenToBody : String -> List SetRenderer.Mixen -> Data
        mixenToBody setName mixen =
            { set = setName, mixen = mixen }

        getSetWhere : Dphones.InputObject.Set_bool_expOptionalFields -> Dphones.InputObject.Set_bool_expOptionalFields
        getSetWhere optionals =
            { optionals
                | tag =
                    Dphones.InputObject.buildString_comparison_exp
                        (\compareOptionals ->
                            { compareOptionals | eq_ = Present routeParams.set }
                        )
                        |> Present
            }

        setParams : Dphones.Query.SetOptionalArguments -> Dphones.Query.SetOptionalArguments
        setParams args =
            { args
                | where_ = Present (Dphones.InputObject.buildSet_bool_exp getSetWhere)
            }

        getMixOrder : Dphones.InputObject.Mixen_order_byOptionalFields -> Dphones.InputObject.Mixen_order_byOptionalFields
        getMixOrder args =
            { args | index = Present Dphones.Enum.Order_by.Asc }

        getMixWhere optionals =
            { optionals
                | list =
                    Dphones.InputObject.buildString_comparison_exp
                        (\compareOptionals ->
                            { compareOptionals
                                | eq_ = Present routeParams.set
                            }
                        )
                        |> Present
            }

        mixParams : Dphones.Query.MixenOptionalArguments -> Dphones.Query.MixenOptionalArguments
        mixParams args =
            { args
                | order_by = Present [ Dphones.InputObject.buildMixen_order_by getMixOrder ]
                , where_ = Present (Dphones.InputObject.buildMixen_bool_exp getMixWhere)
            }
    in
    Dphones.Query.set setParams SetRenderer.setSelection
        |> Hasura.backendTask
        |> BackendTask.andThen
            (\sets ->
                let
                    setName =
                        sets |> List.head |> Maybe.map .title |> Maybe.withDefault ""
                in
                Dphones.Query.mixen mixParams SetRenderer.mixenSelection
                    |> Hasura.backendTask
                    |> BackendTask.map (mixenToBody setName >> Response.render)
            )
        |> Request.succeed


head :
    StaticPayload Data ActionData RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Dphones"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "Dphones logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "mixen by DJ Dope Inc."
        , locale = Nothing
        , title = static.data.set
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data ActionData RouteParams
    -> View (Pages.Msg.Msg Msg)
view maybeUrl sharedModel model static =
    { title = "DJ Dope Inc. " ++ static.data.set
    , body = [ SetRenderer.view static.data ]
    }
