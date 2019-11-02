#!/usr/bin/env bash

# echo installing packages
#
# echo get mux: the sweet router and dispatcher for Go
# go get -u github.com/gorilla/mux

# echo get pflag (https://github.com/spf13/pflag), a drop-in replacement for Go's flag package, implementing POSIX/GNU-style --flags
# go get -u github.com/spf13/pflag

# echo get Viper is a complete configuration solution for Go applications including 12-Factor apps.
# go get -u github.com/spf13/viper


echo "Building monkey-ops go binary"

CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o ./image/monkey-ops ./go/*.go

