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

function dist() {
  ##
  # dist x1 y1 x2 y2
  ##
  local x1=$1
  local y1=$2
  local x2=$3
  local y2=$4
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
  local dist=$(( x1 - x2 + y1 - y2 ))
  echo "$dist"

  # Approach with direct mathematical solution is extremely slow
  # Rather use the least command substitutions you can.
  # More info in README.md
  #local dist=$(( $(abs $((x1 - x2))) + $(abs $((y1 - y2))) ))
}

function is_finite() {
  # 1. Try to move to all axes (x-, x+, y-, y+) and test if the distance to
  #    any other point is same or higher than distance to your original point.
  # 2. If it is, this point in this direction is finite
  # 3. If you prove, that into all axes, there is point with same or higher
  #    distance as to your original point, this point has finite area.

  local x=$1
  local y=$2

  ##
  # x--
  ##
  local finite=0
  local x_fl=$x
  local y_fl=$y
  local d=0
  while [ $x_fl -ge $x_min ] && [ $finite -eq 0 ]; do
    ((--x_fl))
    ((++d))

    for p in "${points[@]}"; do
      # Check if we are comparing same point
      mapfile -d ' ' p_arr <<< "$p"
      [ $x -eq ${p_arr[0]} ] && [ $y -eq ${p_arr[1]} ] && continue

      # Check if point `p` is closer or equal to point left to original `x,y`
      if [ $(dist ${p_arr[0]} ${p_arr[1]} $x_fl $y_fl) -le $d ]; then
        finite=1
        break
      fi
    done
  done

  # If in x-- axis point is infinite, mark it infinite and return
  if [ $finite -eq 0 ]; then
    points_finity_dict["$x $y"]=0
    return
  fi

  ##
  # x++
  ##
  finite=0
  x_fl=$x
  y_fl=$y
  d=0
  while [ $x_fl -le $x_max ] && [ $finite -eq 0 ]; do
    ((++x_fl))
    ((++d))

    for p in "${points[@]}"; do
      # Check if we are comparing same point
      mapfile -d ' ' p_arr <<< "$p"
      [ $x -eq ${p_arr[0]} ] && [ $y -eq ${p_arr[1]} ] && continue

      # Check if point `p` is closer or equal to point right to original `x,y`
      if [ $(dist ${p_arr[0]} ${p_arr[1]} $x_fl $y_fl) -le $d ]; then
        finite=1
        break
      fi
    done
  done

  # If in x++ axis point is infinite, mark it infinite and return
  if [ $finite -eq 0 ]; then
    points_finity_dict["$x $y"]=0
    return
  fi

  ##
  # y--
  ##
  finite=0
  x_fl=$x
  y_fl=$y
  d=0
  while [ $y_fl -ge $y_min ] && [ $finite -eq 0 ]; do
    ((--y_fl))
    ((++d))

    for p in "${points[@]}"; do
      # Check if we are comparing same point
      mapfile -d ' ' p_arr <<< "$p"
      [ $x -eq ${p_arr[0]} ] && [ $y -eq ${p_arr[1]} ] && continue

      # Check if point `p` is closer or equal to point down to original `x,y`
      if [ $(dist ${p_arr[0]} ${p_arr[1]} $x_fl $y_fl) -le $d ]; then
        finite=1
        break
      fi
    done
  done

  # If in y-- axis point is infinite, mark it infinite and return
  if [ $finite -eq 0 ]; then
    points_finity_dict["$x $y"]=0
    return
  fi

  # y++
  finite=0
  x_fl=$x
  y_fl=$y
  d=0
  while [ $y_fl -le $y_max ] && [ $finite -eq 0 ]; do
    ((++y_fl))
    ((++d))

    for p in "${points[@]}"; do
      # Check if we are comparing same point
      mapfile -d ' ' p_arr <<< "$p"
      [ $x -eq ${p_arr[0]} ] && [ $y -eq ${p_arr[1]} ] && continue

      # Check if point `p` is closer or equal to point up to original `x,y`
      if [ $(dist ${p_arr[0]} ${p_arr[1]} $x_fl $y_fl) -le $d ]; then
        finite=1
        break
      fi
    done
  done

  # If in y++ axis point is infinite, mark it infinite and return
  if [ $finite -eq 0 ]; then
    points_finity_dict["$x $y"]=0
    return
  fi

  points_finity_dict["$x $y"]=1
}

# MAIN

# Finite associative array
# 1: finite
# 0: infinite
declare -A points_finity_dict
declare -A points_area_dict

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

# Mark all finite and infinite points
for p in "${points[@]}"; do
  is_finite "$(get_x "$p")" "$(get_y "$p")"
done

# Calculate distance of each point in 2D grid from all other points and
# increment size of this point looked up in associative array.
for (( i = x_min; i <= x_max; i++ )); do
  for (( j = y_min; j <= y_max; j++ )); do
    d=99999
    closest_point=""
    tied=0
    for p in "${points[@]}"; do
      mapfile -d ' ' p_arr <<< "$p"

      # Check if we are comparing the same point
      if [ $i -eq ${p_arr[0]} ] && [ $j -eq ${p_arr[1]} ]; then
        continue
      fi

      # Calculate distance to point p.
      # Do it dirty for performance (look at README.md for notes)
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
      # d_tmp=$(dist $i $j ${p_arr[0]} ${p_arr[1]})
      d_tmp=$(( x1 - x2 + y1 - y2 ))


      # If we tied distance with another point, mark it with `tied`
      if [ $d_tmp -eq $d ]; then
        tied=1
      # Or change lowest distance and mark point in `closest_point`
      elif [ $d_tmp -lt $d ]; then
        tied=0
        closest_point="$p"
        d=$d_tmp
      fi
    done

    # If we found which point belongs to, increment its size in associative array
    if [ $tied -eq 0 ]; then
      if [ -z "${points_area_dict["$closest_point"]}" ]; then
        points_area_dict["$closest_point"]=1
      else
        ((++points_area_dict["$closest_point"]))
      fi
    fi
  done
done


# Find largest finite area
max_finite_area=0
max_finite_area_id=""
for fp in "${!points_finity_dict[@]}"; do
  if [ ${points_finity_dict["$fp"]} -eq 1 ]; then
    if [ ${points_area_dict["$fp"]} -gt $max_finite_area ]; then
      max_finite_area=${points_area_dict["$fp"]}
      max_finite_area_id="$fp"
    fi
  fi
done

# We do not calculate with size of itself, so we are adding +1.
echo "Point $max_finite_area_id is finite and has area of $(( ${points_area_dict["$max_finite_area_id"]} + 1 ))"
