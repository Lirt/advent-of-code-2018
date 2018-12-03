#!/usr/bin/env bash

declare -A canvas
area=0

while read -r LINE; do
  # Parse input lines into variables
  # using created array
  mapfile -t numbers < <(grep -Eo "[[:digit:]]+" <<< "$LINE")
  a=${numbers[1]}
  b=${numbers[2]}
  w=${numbers[3]}
  h=${numbers[4]}

  for (( i = a; i < (a + w); i++ )); do
    for (( j = b; j < (b + h); j++ )); do
      if [ -z "${canvas["$i,$j"]}" ]; then
        canvas["$i,$j"]=1
      else
        [ ${canvas["$i,$j"]} -eq 1 ] && ((++area))
        ((++canvas["$i,$j"]))
      fi
    done
  done
done < "${1:-/dev/stdin}"

echo "Total overlapped area is: $area"
