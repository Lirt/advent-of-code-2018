#!/usr/bin/env bash

declare -A map
serial_number="$1"

for ((i = 1; i <= 300; i++)); do
  for ((j = 1; j <= 300; j++)); do
    power_level=$(( ( ( (i + 10) * j ) + serial_number ) * (i + 10) ))
    map["$i.$j"]=$(( ( (power_level / 100) % 10) - 5 ))
  done
done

declare -A max
declare -A max_coordinates
declare -A map_total_prev

# Initialize previous total power map
for ((i = 1; i <= 300; i++)); do
  for ((j = 1; j <= 300; j++)); do
    map_total_prev["$i.$j"]=0
  done
done

for ((size = 1; size <= 300; size++ )); do
  max["$size"]=-99999
  echo "Size: $size"

  for ((i = 1; i <= 300 - size + 1; i++)); do
    for ((j = 1; j <= 300 - size + 1; j++)); do
      # Read value of previous power rectangle
      total=${map_total_prev["$i.$j"]}

      # Process X axis new numbers
      k=$((i + size - 1))
      for ((l = j; l < j + size; l++)); do
        total=$(( total + map["$k.$l"] ))
      done

      # Process Y axis new numbers
      l=$((j + size - 1))
      for ((k = i; k < i + size - 1; k++)); do
        total=$(( total + map["$k.$l"] ))
      done

      # Add to map of previous size total power
      map_total_prev["$i.$j"]=$total

      # Check if we have new maximum power
      if [ $total -gt ${max["$size"]} ]; then
        max["$size"]=$total
        max_coordinates["$size"]="$i,$j"
      fi
    done
  done
done

echo "Highest total for size 3 is ${max["3"]} in coordinates [${max_coordinates["3"]}]."

for ((size = 1; size <= 300; size++ )); do
  echo "Highest total for size $size is ${max["$size"]} in coordinates [${max_coordinates["$size"]}]."
done
