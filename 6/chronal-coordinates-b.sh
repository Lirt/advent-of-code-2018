#!/usr/bin/env bash

function get_x() {
  echo "${1% *}"
}

function get_y() {
  echo "${1#* }"
}

function abs() {
  echo "${1#-}"
}

# MAIN
# Axis min max variables
x_min=99999
x_max=0
y_min=99999
y_max=0

# Read all point coordinates into array
points=()
i=0
while read -r point; do
  points[$i]="${point//,/}"
  ((i++))
done < "$1"

# Find min and max for x and y axis
for p in "${points[@]}"; do
  x=$(get_x "$p")
  y=$(get_y "$p")
  [ $x -lt $x_min ] && x_min=$x
  [ $x -gt $x_max ] && x_max=$x
  [ $y -lt $y_min ] && y_min=$y
  [ $y -gt $y_max ] && y_max=$y
done

# Calculate size of region, where sum of distances from one
# point to all others is less than 10 000
region_size=0
for (( i = x_min; i <= x_max; i++ )); do
  for (( j = y_min; j <= y_max; j++ )); do
    total_dist=0

    # Iterate over all points and calculate total distance
    for p in "${points[@]}"; do
      # Get X and Y
      mapfile -d ' ' p_arr <<< "$p"

      # If we are standing directly on point, skip
      if [ $i -eq ${p_arr[0]} ] && [ $j -eq ${p_arr[1]} ]; then
        continue
      fi

      # Calculate distance to point p:
      #   Do not use absolute value function `abs`, because it will be slow
      #   Rather do this dirty trick that is explained in README.md
      x1=$i
      y1=$j
      x2=${p_arr[0]}
      y2=${p_arr[1]}
      if [ $x1 -lt $x2 ]; then
        x_tmp=$x1
        x1=$x2
        x2=$x_tmp
      fi
      if [ $y1 -lt $y2 ]; then
        y_tmp=$y1
        y1=$y2
        y2=$y_tmp
      fi
      dp=$(( x1 - x2 + y1 - y2 ))

      # Increment total
      total_dist=$(( total_dist + dp ))
    done

    # If total is less than 10000, incremnent counter
    if [ $total_dist -lt 10000 ]; then
      ((++region_size))
    fi
  done
done

echo "Region size containing all locations with total distance less than 10000 is '$region_size'"
