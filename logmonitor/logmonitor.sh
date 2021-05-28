#!/bin/bash

if [[ ! "$FILE" ]]; then
    echo "Filename absent!" >&2
    exit 1
fi

if [[ ! "$KEYWORD" ]]; then
    echo "Keyword absent!" >&2
fi

echo "Searching for a ${KEYWORD} in file ${FILE}"

grep "$KEYWORD" "$FILE"
