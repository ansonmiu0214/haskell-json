# haskell-json
JSON parser built using Haskell

## Summary
TODO

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
TODO

## Issues
TODO
