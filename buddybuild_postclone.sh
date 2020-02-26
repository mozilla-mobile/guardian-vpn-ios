#!/usr/bin/env bash

CMD="git submodule update --init --checkout"
echo $CMD
`$CMD`

cd WireGuard
REV=`git rev-parse --short HEAD`
echo "WireGuard submodule is at $REV"
