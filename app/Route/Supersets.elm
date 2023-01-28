module Route.Supersets exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Dphones.Enum.Order_by
import Dphones.InputObject
import Dphones.Object
import Dphones.Object.Set
import Dphones.Query
import ErrorPage exposing (ErrorPage)
import FatalError exposing (FatalError)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Hasura
import Head
import Head.Seo as Seo
import Html.Styled as Html
import Html.Styled.Attributes exposing (attribute, class, href, id)
import Pages.Msg
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import RouteBuilder exposing (StatefulRoute, StaticPayload)
import Server.Request as Request
import Server.Response as Response exposing (Response)
import Shared
import View exposing (View)


type alias Data =
    { sets : List Set
    }


type alias Msg =
    ()


type alias ActionData =
    {}


type alias Model =
    {}


type alias RouteParams =
    {}


route : StatefulRoute RouteParams Data actionData {} ()
route =
    RouteBuilder.serverRender
        { head = head
        , data = data
        , action = \_ -> Request.skip "No action."
        }
        |> RouteBuilder.buildNoState { view = view }


type alias Set =
    { tag : String, title : String }


setSelection : SelectionSet Set Dphones.Object.Set
setSelection =
    SelectionSet.map2 Set
        Dphones.Object.Set.tag
        Dphones.Object.Set.title


data : RouteParams -> Request.Parser (BackendTask FatalError (Response Data ErrorPage))
data _ =
    let
        setsToBody : List Set -> Data
        setsToBody sets =
            { sets = sets }

        getSetOrder : Dphones.InputObject.Set_order_byOptionalFields -> Dphones.InputObject.Set_order_byOptionalFields
        getSetOrder args =
            { args | date = Present Dphones.Enum.Order_by.Desc }

        params : Dphones.Query.SetOptionalArguments -> Dphones.Query.SetOptionalArguments
        params args =
            { args
                | order_by = Present [ Dphones.InputObject.buildSet_order_by getSetOrder ]
            }
    in
    Dphones.Query.set params setSelection
        |> Hasura.backendTask
        |> BackendTask.map (setsToBody >> Response.render)
        |> Request.succeed


head :
    StaticPayload Data actionData RouteParams
    -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "comefile.me"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "DJ Dope Inc. super-sets"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "DJ Dope Inc. super-sets"
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data actionData RouteParams
    -> View (Pages.Msg.Msg ())
view _ _ static =
    let
        setsToHtml mix =
            Html.div [ attribute "style" "padding-bottom: 1em" ]
                [ Html.a [ href ("/superset/" ++ mix.tag) ] [ Html.text mix.title ]
                , Html.br [] []
                ]
    in
    { title = "DJ Dope Inc."
    , body =
        [ Html.div [ class "multi-songs" ]
            [ Html.div [ id "amplitude-player", attribute "style" "padding-left: 2em" ]
                [ Html.div [ id "amplitude-right" ]
                    (Html.h2 [ attribute "style" "margin-left: 2em" ] [ Html.text "DJ Dope Incredible mix sets" ] :: List.map setsToHtml static.data.sets)
                ]
            ]
        ]
    }
