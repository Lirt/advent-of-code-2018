#!/usr/bin/env bash
#
###
# USAGE: ./inventory-management-system-a.sh < input.txt
###

twos=0
threes=0

while read -r LINE; do
  declare -A histogram
  two=0
  three=0

  # Create histogram
  while [ -n "$LINE" ]; do
    c=${LINE:0:1}
    LINE="${LINE:1}"
    ((++histogram["$c"]))
  done

  # Iterate over histogram to find how many twos and threes there are
  for k in "${!histogram[@]}"; do
    [ ${histogram[$k]} -eq 2 ] && ((++two))
    [ ${histogram[$k]} -eq 3 ] && ((++three))
  done

  [ $two -ge 1 ] && ((++twos))
  [ $three -ge 1 ] && ((++threes))

  unset histogram
done < "${1:-/dev/stdin}"

###
# Alternative answer based on reddit commentary
# https://www.reddit.com/r/adventofcode/comments/a2aimr/2018_day_2_solutions/eawlxn0
###
# while read -r LINE; do
#   echo "$LINE" | grep -o . | sort | uniq -c | grep -q "^[ \t]*2 " && ((++twos))
#   echo "$LINE" | grep -o . | sort | uniq -c | grep -q "^[ \t]*3 " && ((++threes))
# done < "${1:-/dev/stdin}"

echo "Checksum is: $((twos * threes))"
