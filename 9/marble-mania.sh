#!/usr/bin/env bash

# This solution is extremely slow, mostly because
# of array slicing, which can be proven by simple
# snippet.

declare -a list
declare -A score
cur=0
pid=1

players=$(grep -Eo "^[[:digit:]]+" "$1")
points=$(grep -Eo "[[:digit:]]+ points$" "$1" | awk '{print $1}')

echo "Number of players: $players"
echo "Last marble: $points"

list+=( 0 )

for (( i = 1; i <= points; i++ )); do
  # Find a place to put new number
  list_len=${#list[@]}
  cur=$((cur + 2))

  if (( i % 23 == 0 )); then
    # Handle 23
    cur=$((cur - 7 - 2))

    # Overflow to left
    while [ $cur -lt 0 ]; do
      cur=$(( list_len + cur ))
    done

    # Increment score
    if [ -z "${score["$pid"]}" ]; then
      score["$pid"]=${list["$cur"]}
    else
      score["$pid"]=$(( score["$pid"] + list["$cur"] ))
    fi
    score["$pid"]=$(( score["$pid"] + i ))

    # Remove element 7 marbles to the left
    unset list["$cur"]
    list=( "${list[@]}" )
    list_len=${#list[@]}
  elif [ $cur -gt $list_len ]; then
    # Handle overflow
    cur=$(( cur - list_len ))
    list=( "${list[@]:0:$cur}" "$i" "${list[@]:$cur}" )
  elif [ $cur -eq $list_len ]; then
    list+=( "$i" )
  else
    list=( "${list[@]:0:$cur}" "$i" "${list[@]:$cur}" )
  fi

  if [ $pid -eq $players ]; then
    pid=1
  else
    ((++pid))
  fi
done

max=0
for n in "${score[@]}"; do
  [ $n -gt $max ] && max=$n
done
echo "Highest score is: $max"
