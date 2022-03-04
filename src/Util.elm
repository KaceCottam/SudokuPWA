module Util exposing (getIndeces, getIndeces2)

import List exposing (map)
import List.Extra exposing (getAt)
import Maybe exposing (withDefault)
import Maybe.Extra exposing (combine)
import Basics.Extra exposing (flip)

getIndeces : List Int -> List a -> List (Maybe a)
getIndeces is xs = map (flip getAt xs) is

getIndeces2 : List Int -> List a -> List a
getIndeces2 is xs =  withDefault [] <| combine <| getIndeces is xs