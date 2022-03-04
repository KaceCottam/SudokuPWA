module SudokuBoard exposing
    ( SudokuBoard, Position, SudokuError(..), SingleDigitBoard, MultiDigitBoard
    , makeBoard, setValue, toggleMark, verify
    )

{-| This library provides the framework for emulating a Sudoku Puzzle.

-}

import List exposing (all, filter, length, map, map2)
import List.Extra exposing (find, findIndices, setAt)
import Maybe.Extra exposing (isJust, or)
import String exposing (fromChar, toInt, toList)


{-| A position in a sudoku board between 0 and 80 (inclusive).

Positions correspond to the following slots:

```js
00 01 02 | 03 04 05 | 06 07 08
09 10 11 | 12 13 14 | 15 16 17
18 19 20 | 21 22 23 | 24 25 26
---------+----------+---------
27 28 29 | 30 31 32 | 33 34 35
36 37 38 | 39 40 41 | 42 43 44
45 46 47 | 48 49 50 | 51 52 53
---------+----------+---------
54 55 56 | 57 58 59 | 60 61 62
63 64 65 | 66 67 68 | 69 70 71
72 73 74 | 75 76 77 | 78 79 80
```

-}
type alias Position =
    Int


{-| List of 81 cells.

Each cell can only hold up to one digit.

-}
type alias SingleDigitBoard =
    List (Maybe Int)


{-| A sparse matrix containing position and value.
-}
type alias MultiDigitBoard =
    List ( Position, Int )


{-| A sudoku board containing given digits, corner pencil marks,
center pencil marks, and answer pencil marks.
-}
type alias SudokuBoard =
    { givenMarks : SingleDigitBoard
    , cornerMarks : MultiDigitBoard
    , centerMarks : MultiDigitBoard
    , answerMarks : SingleDigitBoard
    , solution : SingleDigitBoard
    }

{-|-}
type SudokuError
    = NotFullError
    | ConflictError (List Position)


union : SingleDigitBoard -> SingleDigitBoard -> SingleDigitBoard
union left right =
    map2 or left right


getBoard : SudokuBoard -> SingleDigitBoard
getBoard { givenMarks, answerMarks } =
    union givenMarks answerMarks

{-|-}
verify : SudokuBoard -> Result SudokuError ()
verify b =
    let
        board =
            getBoard b

        allFilled =
            all isJust board

        invalidPositions =
            findIndices identity <| map2 (\x y -> isJust y && x /= y) b.solution board
    in
    if length invalidPositions /= 0 then
        Err <| ConflictError invalidPositions

    else if not allFilled then
        Err NotFullError

    else
        Ok ()

{-|-}
setValue : Position -> Maybe Int -> SingleDigitBoard -> SingleDigitBoard
setValue =
    setAt

{-|-}
toggleMark : Position -> Int -> MultiDigitBoard -> MultiDigitBoard
toggleMark pos val board =
    let
        item =
            ( pos, val )
    in
    if isJust <| find ((==) item) board then
        filter ((/=) item) board

    else
        item :: board

{-|-}
makeBoard : String -> String -> String -> SudokuBoard
makeBoard solutionS givenS answerS =
    let
        chrToJust : Char -> Maybe Int
        chrToJust c =
            if c >= '1' && c <= '9' then
                toInt <| fromChar c

            else
                Nothing

        fromStr : String -> SingleDigitBoard
        fromStr =
            map chrToJust << toList
    in
    { givenMarks = fromStr givenS
    , answerMarks = fromStr answerS
    , centerMarks = []
    , cornerMarks = []
    , solution = fromStr solutionS
    }



-- can test with example from https://github.com/navshaikh/sudoku-api
-- {
--     puzzle   = "9715..842..69...1....8.2..95.....79...76.83...28.....57..1.5....4...91..819..7254",
--     solution = "971536842286974513354812679563421798497658321128793465732145986645289137819367254",
-- }
