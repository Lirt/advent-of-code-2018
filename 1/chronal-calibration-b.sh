#!/usr/bin/env bash

declare -A dict

dict[0]=1
f=0

while true; do
    while read -r n; do
        f=$((f + n))
        if [ "${dict[$f]}" = "1" ]; then
            echo "duplicate is $f"
            exit 0
        fi
        dict[$f]=1
    done < "${1-/dev/stdin}"
done
