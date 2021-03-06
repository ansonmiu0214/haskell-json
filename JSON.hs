import Data.Char
import Data.Maybe
import Text.Read
import System.Environment

--
-- Data type
--
type Object = [(Key, Value)]
type Key = String

data Value = Nil |
             One BaseType |
             Many [BaseType]
        deriving (Eq)

data BaseType = Num Int | 
                Boolean Bool | 
                Str String | 
                Obj Object
        deriving (Eq)

instance Show Value where
  show Nil = "[]"
  show (One val) = show val
  show (Many vals) = show vals

instance Show BaseType where
  show (Num x) = show x
  show (Boolean x) = show x
  show (Str x) = show x
  show (Obj x) = show x

--
-- Utility functions
--
trim :: String -> String
trim = dropWhile isSpace

booleanTable = [("true", True), ("false", False)]

--
-- Parsing functions
--
parse :: String -> Object
parse x
  | rest == ""        = obj
  | all isSpace rest  = obj  
  | otherwise         = error ("JSON parse error - extraneous input: " ++ rest)
  where
    (obj, rest) = parse' x

parse' :: String -> (Object, String)
parse' []
  = ([], "")
parse' xs@(c:cs)
  | c == '{'  = res
  | xs /= ys  = parse' ys
  | otherwise = error ("JSON parse' error: " ++ xs)
  where
    ys = trim xs
    res@(obj, rest) = parseObj (trim cs)

parseObj :: String -> ([(Key, Value)], String)
parseObj []
  = ([], "")
parseObj xs@(c:cs)
  | c == '"'  = (item:items, others)
  | c == ','  = parseObj (trim cs)
  | c == '}'  = ([], cs)
  | otherwise = error ("JSON parseObj error: " ++ (trim cs))
  where
    (item, rest) = parseItem xs
    (items, others) = parseObj (trim rest)

parseItem :: String -> ((Key, Value), String)
parseItem xs@(c:cs)
  | c == '"'  = ((key, value), others)
  | otherwise = error ("JSON parseItem error: " ++ xs)
  where
    (key, rest) = parseKey cs
    (value, others) = parseValue (dropWhile (\x -> (isSpace x) || (x == ':')) rest)

parseKey :: String -> (Key, String)
parseKey []
  = ("", "")
parseKey (c:cs)
  | c == '"'  = ("", cs)
  | otherwise = (c:key, rest)
  where
    (key, rest) = parseKey cs

parseValue :: String -> (Value, String)
parseValue xs@(c:cs)
  | c == '[' && arrVal == []  = (Nil, rest')
  | c == '['                  = (Many arrVal, rest') 
  | otherwise                 = (One baseVal, rest)
  where
    (baseVal, rest) = parseBase xs
    (arrVal, rest') = parseArray cs

parseBase :: String -> (BaseType, String)
parseBase xs@(c:cs)
  | c == '"'  = (baseVal, rest)
  | c == '{'  = (Obj objVal, rest')
  | otherwise = error ("JSON parseBase error: " ++ xs)
  where
    (baseVal, rest) = parseLiteral cs
    (objVal, rest') = parse' xs

parseArray :: String -> ([BaseType], String)
parseArray xs@(c:cs)
  | c == ']'  = ([], cs)
  | c == ','  = parseArray (trim cs)
  | otherwise = (item:arr, rest')
  where
    (item, rest) = parseBase (trim xs)
    (arr, rest') = parseArray (trim rest)

parseLiteral :: String -> (BaseType, String)
parseLiteral x
  | val == []             = (Str "", rest)
  | maybeBool /= Nothing  = (Boolean (fromJust maybeBool), rest)
  | otherwise             = (maybe (Str val) (\y -> Num y) maybeInt, rest)
  where
    (val, rest) = extractLiteral x
    maybeBool = lookup val booleanTable
    maybeInt = parseInt val

extractLiteral :: String -> (String, String)
extractLiteral []
  = ("", "")
extractLiteral (c:cs)
  | c == '"'  = ("", cs)
  | otherwise = (c:val, rest)
  where
    (val, rest) = extractLiteral cs

parseString :: String -> (String, String)
parseString []
  = ("", "")
parseString (c:cs)
  | c == '"'  = ("", cs)
  | otherwise = (c:val, rest)
  where
    (val, rest) = parseString cs

parseInt :: String -> Maybe Int
parseInt = readMaybe

queryJSON :: Object -> String -> Value
queryJSON _ ""
  = Nil
queryJSON json query
  | key == ""           = error "JSON query error: empty key"
  | maybeVal == Nothing = error ("JSON query error: failed to find " ++ query)
  | otherwise           = queryVal (fromJust maybeVal) rest
  where
    key = takeWhile (\x -> x /= '.') query
    rest = drop 1 (dropWhile (\x -> x /= '.') query)
    maybeVal = lookup key json

queryVal :: Value -> String -> Value
queryVal val ""
  = val
queryVal (One (Obj obj)) query
  = queryJSON obj query
queryVal _ query
  = error ("JSON query error: failed to find " ++ query)

stringify :: Object -> String
stringify x = error "TODO implement stringify"

--
-- Main
--
main = do
  putStrLn "Enter file name: "
  fileName <- getLine
  putStrLn ("Loading " ++ fileName ++ " ...")
  contents <- readFile fileName
  putStrLn "... done!"
  let parsedContent = parse contents
  putStrLn "Parsed content: "
  print parsedContent
  putStrLn "Enter query: "
  query <- getLine
  putStrLn "Extracting query..."
  let result = queryJSON parsedContent query
  print result

--
-- Sample JSONs
--
json1 = "{}"
json2 = "   {}  "
json3 = "{ \"name\": \"John Doe\" }"
json4 = "{ \"name\": \"John Doe\", \"age\": \"14\", \"male\": \"true\" }"
json5 = "{ \"person\": " ++ json3 ++ "}"
json6 = "{ \"days\": [\"14\", \"18\", \"13\"] }"
json7 = "{\r\n    \"glossary\": {\r\n        \"title\": \"example glossary\",\r\n\t\t\"GlossDiv\": {\r\n            \"title\": \"S\",\r\n\t\t\t\"GlossList\": {\r\n                \"GlossEntry\": {\r\n                    \"ID\": \"SGML\",\r\n\t\t\t\t\t\"SortAs\": \"SGML\",\r\n\t\t\t\t\t\"GlossTerm\": \"Standard Generalized Markup Language\",\r\n\t\t\t\t\t\"Acronym\": \"SGML\",\r\n\t\t\t\t\t\"Abbrev\": \"ISO 8879:1986\",\r\n\t\t\t\t\t\"GlossDef\": {\r\n                        \"para\": \"A meta-markup language, used to create markup languages such as DocBook.\",\r\n\t\t\t\t\t\t\"GlossSeeAlso\": [\"GML\", \"XML\"]\r\n                    },\r\n\t\t\t\t\t\"GlossSee\": \"markup\"\r\n                }\r\n            }\r\n        }\r\n    }\r\n}"
