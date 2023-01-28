-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Dphones.Object.Mixen_var_samp_fields exposing (..)

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


index : SelectionSet (Maybe Float) Dphones.Object.Mixen_var_samp_fields
index =
    Object.selectionForField "(Maybe Float)" "index" [] (Decode.float |> Decode.nullable)


plays : SelectionSet (Maybe Float) Dphones.Object.Mixen_var_samp_fields
plays =
    Object.selectionForField "(Maybe Float)" "plays" [] (Decode.float |> Decode.nullable)
