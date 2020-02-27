#!/usr/bin/env bash

CMD="git submodule --deinit"
echo $CMD
`$CMD`

CMD="git submodule update --init"
echo $CMD
`$CMD`

cd WireGuard
REV=`git rev-parse --short HEAD`
echo "WireGuard submodule is at $REV"
