#!/usr/bin/env bash

CMD="git submodule deinit -f --all"
echo $CMD
echo `$CMD`

CMD2="git submodule update --init"
echo $CMD2
echo `$CMD2`
