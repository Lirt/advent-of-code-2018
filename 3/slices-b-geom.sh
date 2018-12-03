#!/usr/bin/env bash

###
# x1,y1
#      -------
#      |     |
#      |     |
#      |     |
#      -------x2,y2
#                    x3,y3
#                         -------
#                         |     |
#                         |     |
#                         |     |
#                         -------x4,y4
###

declare -A lines
i=0

while read -r LINE; do
  mapfile -t numbers < <(grep -Eo "[[:digit:]]+" <<< "$LINE")
  lines["$i"]=${numbers[*]}
  ((++i))
done < "${1:-/dev/stdin}"

for (( i = 0; i < ${#lines[@]}; i++ )); do
  read -ra numbers <<< "${lines[$i]}"
  ID1=${numbers[0]}
  x1=${numbers[1]}
  y1=${numbers[2]}
  x2=$((numbers[3] + x1))
  y2=$((numbers[4] + y1))

  for (( j = 0; j < ${#lines[@]}; j++ )); do
    # Skip comparing the same rectangle
    [ $i -eq $j ] && continue

    read -ra numbers <<< "${lines[$j]}"
    x3=${numbers[1]}
    y3=${numbers[2]}
    x4=$((numbers[3] + x3))
    y4=$((numbers[4] + y3))

    # Overlap by default
    overlap=1

    # Or prove wrong
    if [ $x1 -gt $x4 ] || [ $x2 -lt $x3 ]; then
      overlap=0
    elif [ $y1 -gt $y4 ] || [ $y2 -lt $y3 ]; then
      overlap=0
    fi

    # If it overlaps, break the loop
    [ $overlap -eq 1 ] && break
  done

  # If no rectangle overlaps, write its ID and exit
  [ $overlap -eq 0 ] && echo "Rectangle $ID1 does not overlap with any other rectangle" && exit 0
done
