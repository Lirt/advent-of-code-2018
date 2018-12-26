#!/usr/bin/env bash

function has_neighbor() {
  local x_pos="$1"
  local y_pos="$2"
  local -n canvas_ref="$3"

  local has_neigh=0

  for ((i = x_pos - 1; i <= x_pos + 1; i++)); do
    for ((j = y_pos - 1; j <= y_pos + 1; j++)); do
      [ $i -eq $x_pos ] && [ $j -eq $y_pos ] && continue
      if [ -n "${canvas_ref["$i.$j"]}" ]; then
        has_neigh=1
        break
      fi
    done
    if [ $has_neigh -eq 1 ]; then
      break
    fi
  done

  echo "$has_neigh"
}

function print_canvas() {
  local -n canvas_ref="$1"

  for ((j = 140; j < 170; j++)); do
    for ((i = 100; i < 180; i++)); do
      pos="$i.$j"
      if [ -z "${canvas_ref["$pos"]}" ]; then
        echo -n " "
      else
        echo -n "*"
      fi
    done
    echo ""
  done

  for key in "${!canvas_ref[@]}"; do
    echo "$key"
  done
}


declare -A points
declare -A canvas
points_len=0

while read -r LINE; do
  x_position=$(grep -o "position=<.*> " <<< "$LINE")
  x_position=${x_position%%,*}
  x_position=$(grep -Eo "[-]*[0-9]+$" <<< "$x_position")

  y_position=$(grep -o "position=<.*> " <<< "$LINE")
  y_position=${y_position##*,}
  y_position=$(grep -Eo "[-]*[0-9]+" <<< "$y_position")

  x_velocity=$(grep -o "velocity=<.*>$" <<< "$LINE")
  x_velocity=${x_velocity%%,*}
  x_velocity=$(grep -Eo "[-]*[0-9]+" <<< "$x_velocity")

  y_velocity=$(grep -o "velocity=<.*>$" <<< "$LINE")
  y_velocity=${y_velocity##*,}
  y_velocity=$(grep -Eo "[-]*[0-9]+" <<< "$y_velocity")

  points["$points_len.x_pos"]=$x_position
  points["$points_len.y_pos"]=$y_position
  points["$points_len.x_vel"]=$x_velocity
  points["$points_len.y_vel"]=$y_velocity

  ((++points_len))
done < "$1"

everyone_has_neigh=0
iteration=0

while [ $everyone_has_neigh -ne 1 ]; do
  # Clean canvas
  unset canvas
  declare -A canvas

  # Move points
  for (( i = 0; i < points_len; i++ )); do
    points["$i.x_pos"]=$(( points["$i.x_pos"] + points["$i.x_vel"] ))
    points["$i.y_pos"]=$(( points["$i.y_pos"] + points["$i.y_vel"] ))
  done

  # Create canvas
  for (( i = 0; i < points_len; i++ )); do
    x_position=${points["$i.x_pos"]}
    y_position=${points["$i.y_pos"]}
    canvas["$x_position.$y_position"]=1
  done

  # Check if every point has neighbor
  everyone_has_neigh=1
  for (( i = 0; i < points_len; i++ )); do
    x_position=${points["$i.x_pos"]}
    y_position=${points["$i.y_pos"]}
    has_neigh=$(has_neighbor "$x_position" "$y_position" "canvas")
    if [ "$has_neigh" -eq 0 ]; then
      everyone_has_neigh=0
      break
    fi
  done

  ((++iteration))
done

print_canvas "canvas"
echo "Final iteration is $iteration"
