import Data.Char

--
-- Data type
--
type Object = [(Key, Value)]
type Key = String

data Value = Nil | 
             One BaseType |
             Many [BaseType]
        deriving (Eq, Show)

data BaseType = Num Int | 
                Boolean Bool | 
                Str String | 
                Obj Object
        deriving (Eq, Show)

--
-- Utility functions
--
trim :: String -> String
trim = dropWhile isSpace


--
-- Parsing functions
--
parse :: String -> Object
parse x = error "TODO parse"

stringify :: Object -> String
stringify x = error "TODO implement stringify"

--
-- Sample JSONs
--
json1 = "{}"
json2 = "   {}  "
json3 = "{ \"name\": \"John Doe\", \"age\": \"14\", \"male\": \"true\" }"
