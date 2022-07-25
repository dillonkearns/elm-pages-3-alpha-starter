module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import DataSource
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Events
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Time
import View exposing (View)


type alias DetalleCambio =
    { path : Path
    , query : Maybe String
    , fragment : Maybe String
    }


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
    }


type Msg
    = SharedMsg SharedMsg
    | MenuClicked
    | OnPageChange DetalleCambio
    | TimeNow Time.Posix
    | BotonActTimePressed


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    { showMenu : Bool
    , time : Maybe Time.Posix
    }


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : Path
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init flags maybePagePath =
    ( { showMenu = False
      , time = Nothing
      }
    , Effect.none
    )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SharedMsg globalMsg ->
            ( model, Effect.none )

        MenuClicked ->
            ( { model | showMenu = not model.showMenu }, Effect.none )

        OnPageChange _ ->
            ( model, Effect.GetTheTime TimeNow )

        BotonActTimePressed ->
            ( model, Effect.GetTheTime TimeNow )

        TimeNow time ->
            ( { model | time = Just time }
            , Effect.none
            )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


view :
    Data
    ->
        { path : Path
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : Html msg, title : String }
view sharedData page model toMsg pageView =
    { body =
        Html.div []
            [ Html.nav []
                [ Html.button
                    [ Html.Events.onClick MenuClicked ]
                    [ Html.text
                        (if model.showMenu then
                            "Close Menu"

                         else
                            "Open Menu"
                        )
                    ]
                , if model.showMenu then
                    Html.ul []
                        [ Html.li [] [ Html.text "Menu item 1" ]
                        , Html.li [] [ Html.text "Menu item 2" ]
                        ]

                  else
                    Html.text ""
                , case model.time of
                    Nothing ->
                        Html.text ""

                    Just tiempo ->
                        Html.p []
                            [ Html.text
                                (String.join ":" <|
                                    List.map
                                        String.fromInt
                                        [ Time.toHour Time.utc tiempo
                                        , Time.toSecond Time.utc tiempo
                                        , Time.toMillis Time.utc tiempo
                                        ]
                                )
                            ]
                , Html.button [ Html.Events.onClick BotonActTimePressed ]
                    [ Html.text
                        "New Time"
                    ]
                ]
                |> Html.map toMsg
            , Html.main_ [] pageView.body
            ]
    , title = pageView.title
    }
