#!/usr/bin/env bash

CMD="git submodule deinit -f --all"
echo $CMD
`$CMD`

CMD2="git submodule update --init"
echo $CMD2
`$CMD2`

cd WireGuard
REV=`git rev-parse --short HEAD`
echo "WireGuard submodule is at $REV"
