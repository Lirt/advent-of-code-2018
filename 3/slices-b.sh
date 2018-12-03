#!/usr/bin/env bash

declare -A canvas

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
        canvas["$i,$j"]=0
      else
        canvas["$i,$j"]=1
      fi
    done
  done
done < "${1:-/dev/stdin}"


while read -r LINE; do
  # Parse input lines into variables
  # using created array
  mapfile -t numbers < <(grep -Eo "[[:digit:]]+" <<< "$LINE")
  ID=${numbers[0]}
  a=${numbers[1]}
  b=${numbers[2]}
  w=${numbers[3]}
  h=${numbers[4]}

  overlap=1
  for (( i = a; i < (a + w); i++ )); do
    for (( j = b; j < (b + h); j++ )); do
      [ "${canvas["$i,$j"]}" = "1" ] && overlap=0 && break
    done
    [ $overlap -eq 0 ] && break
  done

  [ $overlap -eq 1 ] && echo "ID: $ID @ [$i,$j]: ${canvas["$i,$j"]}"

done < "${1:-/dev/stdin}"
