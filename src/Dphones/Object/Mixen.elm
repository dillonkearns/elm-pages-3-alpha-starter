-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Dphones.Object.Mixen exposing (..)

import Dphones.InputObject
import Dphones.Interface
import Dphones.Object
import Dphones.Scalar
import Dphones.ScalarCodecs
import Dphones.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


index : SelectionSet (Maybe Int) Dphones.Object.Mixen
index =
    Object.selectionForField "(Maybe Int)" "index" [] (Decode.int |> Decode.nullable)


list : SelectionSet String Dphones.Object.Mixen
list =
    Object.selectionForField "String" "list" [] Decode.string


plays : SelectionSet Int Dphones.Object.Mixen
plays =
    Object.selectionForField "Int" "plays" [] Decode.int


title : SelectionSet String Dphones.Object.Mixen
title =
    Object.selectionForField "String" "title" [] Decode.string


url : SelectionSet String Dphones.Object.Mixen
url =
    Object.selectionForField "String" "url" [] Decode.string
