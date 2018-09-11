# haskell-json
JSON parser built using Haskell

## Summary
This is an implementation of `JSON.parse()` from JavaScript, but using a purely functional programming language in Haskell.

### Data Representation
The top level `Object` models a JavaScript object as a list of key-value pairs `[(Key, Value)]`. The `Value`s can be `One` singular or `Many` in an array. Such constructors can hold `Int`, `Bool`, `String` (as the base cases) as well as other `Object`s, thus achieving the recursive nature of the data type.

## Dependencies
* **ghci** - The Glorious Glasgow Haskell Compilation System, tested on version 8.0.1.

## Install/Build
Makefile included for compilation.

* To **build**, run `make all`.
* To **clean**, run `make clean`.

### Testing sample strings
Load the source file into the interpreter using `ghci JSON.hs`.
You can `parse` and `queryJSON` the stringified samples, `json1` ... `json7`.
```
$ ghci JSON.hs
(omitted)
*Main> parse json3
[("name",One (Str "John Doe"))]
*Main> queryJSON (parse json5) "person.name"
One (Str "John Doe")
```

### Parsing from file
Run the Makefile first. Load a custom JSON file into the parser using `./JSON`.
The program will prompt for the filename and a query.
```
$ ./JSON
Enter file name:
example.json
Parsed content:
(omitted)
Enter query:
quiz.sport.q1
Extracting query...
(omitted)
```

## Learning
This project allowed me to refine my understanding of recursion and improve my ability to break down problems into simpler terms. All the utility functions used by `parse` are predicated on the return values of mutual recursive calls.

### parseLiteral :: String -> (BaseType, String)

### parseArray :: String -> ([BaseType], String)

### parseBase :: String -> (BaseType, String)

### parseValue :: String -> (Value, String)

### parseKey :: String -> (Key, String)
* Handles the input string and returns the parsed `Key` and any extraneous input.
* **Precondition:** the opening double quote is handled by the parent.
* Base case defined on the closing quote: end of key reached, so just return `("", rest)` where `rest` is the tail of the input string.
* Recursive case depends on recursive calls to itself - prepend the head onto the key returned by the recursive call made on the tail.

### parseItem :: String -> ((Key, Value), String)

### parseObj :: String -> ([(Key, Value)], String)
* Handles the input string and returns the parsed `Object` and any extraneous input.
* Base case defined on the empty string: no key-value pairs detected, so return `([], "")`.
* Recursive case depends on the recursive calls of `parseItem` and itself:
  * Calling `parseItem` on the same input returns the required `item :: (Key, Value)` and the unprocessed `rest`.
  * Calling `parseObj` on the `rest` returns the other `items :: [(Key, Value)]`, so the full list is obtained by `item:items`.

## Next steps
1. Error handling on parsing.
2. Implementing `stringify` - involves recursively handling the data types.
3. Improving how the parsed data structure is `show`n on screen.
