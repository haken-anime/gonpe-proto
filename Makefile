MAKEFLAGS=--no-builtin-rules \
          --no-builtin-variables \
		  --always-make

# Fixes a bug in OSX Make with exporting PATH environment variables
# See: http://stackoverflow.com/questions/11745634/setting-path-variable-from-inside-makefile-does-not-work-for-make-3-81
OS := $(shell uname -s)
ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
BIN_PATH := $(ROOT)/bin
SCRIPT_PATH := $(ROOT)/scripts
ifeq ($(OS),Darwin)
export SHELL := $(shell echo $$SHELL)
endif

# set path
export PATH := $(BIN_PATH):$(SCRIPT_PATH):$(PATH)

.PHONY: setup clean version

init:
	mkdir -p $(BIN_PATH)

setup: install/tool gobuild

install/tool: init
	install_protoc.sh $(BIN_PATH)
	curl -sSL https://github.com/uber/prototool/releases/download/v1.5.0/prototool-$$(uname -s)-$$(uname -m) -o $(BIN_PATH)/prototool && chmod +x $(BIN_PATH)/prototool

gobuild: init
	go build -o $(BIN_PATH)/protoc-gen-go github.com/golang/protobuf/protoc-gen-go
	go build -o $(BIN_PATH)/protoc-gen-gohttp github.com/nametake/protoc-gen-gohttp

clean:
	rm -rf $(BIN_PATH)

version:
	protoc --version
	prototool version

gen:
	prototool generate .

lint:
	prototool lint .
