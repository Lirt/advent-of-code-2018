#!/usr/bin/env bash

function react() {
  local len=0
  local word="$1"

  while [ $len -ne ${#word} ]; do
    len=${#word}
    for c in {a..z}; do
      uc=${c^}
      word=${word//$c$uc/}
      word=${word//$uc$c/}
    done
  done

  echo "$len"
}

# Part 1
read -r word < input.txt
echo "Length of reacted unit is: $(react "$word")"

# Part 2
read -r word < input.txt
min_len=99999

for c in {a..z}; do
  len=$(react "$(tr -d "$c${c^}" <<< "$word")")
  [ ${len} -lt $min_len ] && min_len=${len}
  # echo "For input with deleted letters "$c${c^}", reacted length is $len"
done

echo "Shortest polymer has length $min_len"
