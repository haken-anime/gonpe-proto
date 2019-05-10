MAKEFLAGS=--no-builtin-rules \
          --no-builtin-variables \
		  --always-make

OS := $(shell uname -s)
ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
# Fixes a bug in OSX Make with exporting PATH environment variables
# See: http://stackoverflow.com/questions/11745634/setting-path-variable-from-inside-makefile-does-not-work-for-make-3-81
ifeq ($(OS),Darwin)
export SHELL := $(shell echo $$SHELL)
endif

# path definition
BIN_PATH := $(ROOT)/bin
PROTO_PATH := $(ROOT)/gonpe
GEN_PATH := $(ROOT)/gen
GOOGLE_PROTO_PATH := $(ROOT)/google
SCRIPT_PATH := $(ROOT)/scripts

export PATH := $(BIN_PATH):$(SCRIPT_PATH):$(PATH)

# version definition
PROTOC_VERSION := 3.7.1
PROTOTOOL_VERSION := 1.7.0


.PHONY: all version

all: setup lint gen

setup: clean/tool install/tool gobuild

init:
	mkdir -p $(BIN_PATH)

install/tool: init
	install_protoc.sh $(PROTOC_VERSION) $(BIN_PATH) $(GOOGLE_PROTO_PATH)
	curl -sSL https://github.com/uber/prototool/releases/download/v$(PROTOTOOL_VERSION)/prototool-$$(uname -s)-$$(uname -m) -o $(BIN_PATH)/prototool && chmod +x $(BIN_PATH)/prototool

gobuild: init
	go build -o $(BIN_PATH)/protoc-gen-go github.com/golang/protobuf/protoc-gen-go
	go build -o $(BIN_PATH)/protoc-gen-gohttp github.com/nametake/protoc-gen-gohttp

clean/tool:
	rm -rf $(BIN_PATH)
	rm -rf $(GOOGLE_PROTO_PATH)

clean/gen:
	rm -rf $(GEN_PATH)

version:
	protoc --version
	prototool version

gen: clean/gen
	prototool generate $(PROTO_PATH)


lint:
	prototool lint $(PROTO_PATH)
