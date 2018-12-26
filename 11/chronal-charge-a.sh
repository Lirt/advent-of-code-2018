#!/usr/bin/env bash

set -u

declare -A map
serial_number="$1"

for ((i = 1; i <= 300; i++)); do
  for ((j = 1; j <= 300; j++)); do
    power_level=$(( ( ( (i + 10) * j ) + serial_number ) * (i + 10) ))
    map["$i.$j"]=$(( ( (power_level / 100) % 10) - 5 ))
  done
done

max=0
max_coordinates=""
for ((i = 1; i <= 300 - 2; i++)); do
  echo "$i"
  for ((j = 1; j <= 300 - 2; j++)); do
    total=0
    for ((k = i; k <= i + 2; k++)); do
      for ((l = j; l <= j + 2; l++)); do
        total=$(( total + map["$k.$l"] ))
      done
    done
    if [ $total -gt $max ]; then
      max=$total
      max_coordinates="$i,$j"
    fi
  done
done

echo "Highest total for size 3 is $max in coordinates [$max_coordinates]."
