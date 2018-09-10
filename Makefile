all:  JSON

JSON: 
	ghc -o JSON JSON.hs

clean:  
	rm JSON JSON.hi JSON.o

.PHONY: clean
