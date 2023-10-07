all: compile

deps:
	mix deps.get

compile dialyzer check:
	mix $@

.PHONY: deps
