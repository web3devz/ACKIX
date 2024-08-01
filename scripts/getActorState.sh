#!/bin/bash

## USAGE:
## getActorState.sh programSrc actorId

## Prints actor state according to its definition
## in programSrc, from the blockchain account with
## address = actorId

CONFIG_PATH=~/scripts/tonos-cli.conf.json
SOURCE="$1"
ACTORID="$2"

if [ $# -ne 2 ]; then
    echo "USAGE: getActorState.sh programSrc actorId"
    echo
    echo "Prints  actor state according to its definition"
    echo "in programSrc, from the blockchain account with address = actorId"
    echo "================================================================="
    echo "Warning: tonos-cli configuration is put inside the script"
    echo "Warning: Tools 'LHGenDes' and 'fift' has to be in the PATH"
    echo "================================================================="
    exit 1
fi

tonos-cli -c $CONFIG_PATH account $ACTORID | \
    grep data_boc | \
    cut -d":" -f 2 | \
    sed 's/^[[:space:]]*//' | \
    xxd -r -p > data.c4

~/src/Ackixhouse/src/LHGenDes/bin/Debug/net6.0/LHGenDes $SOURCE ActorState
fift ./reader.fif