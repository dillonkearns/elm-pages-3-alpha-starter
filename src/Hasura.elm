module Hasura exposing (backendTask)

import BackendTask exposing (BackendTask)
import BackendTask.Custom
import BackendTask.Http
import FatalError exposing (FatalError)
import Graphql.Document
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode
import Json.Encode as Encode


backendTask : SelectionSet value RootQuery -> BackendTask FatalError value
backendTask selectionSet =
    BackendTask.Custom.run "environmentVariable" (Encode.string "ELM_APP_URL") Decode.string
        |> BackendTask.allowFatal
        |> BackendTask.andThen
            (\url ->
                BackendTask.Custom.run "environmentVariable" (Encode.string "ELM_APP_SECRET") Decode.string
                    |> BackendTask.allowFatal
                    |> BackendTask.andThen
                        (\secret ->
                            BackendTask.Http.request
                                { url = url
                                , method = "POST"
                                , headers =
                                    [ ( "x-hasura-admin-secret", secret )
                                    , ( "Content-Type", "application/json" )
                                    ]
                                , body =
                                    BackendTask.Http.jsonBody
                                        (Encode.object
                                            [ ( "query"
                                              , selectionSet
                                                    |> Graphql.Document.serializeQuery
                                                    |> Encode.string
                                              )
                                            ]
                                        )
                                , retries = Nothing
                                , timeoutInMs = Nothing
                                }
                                (selectionSet
                                    |> Graphql.Document.decoder
                                    |> BackendTask.Http.expectJson
                                )
                                |> BackendTask.allowFatal
                        )
            )
