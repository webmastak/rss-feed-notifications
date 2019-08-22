FILE:= $(shell basename $(shell pwd))

build:
	@mkdir -p bin
	@crystal build --release --no-debug -s src/$(FILE).cr -o bin/$(FILE)
