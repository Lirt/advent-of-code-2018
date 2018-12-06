# 6. Chronal Coordinates

Elegant solution using functions is extremely slow. There is too big performance penalty of calling a lot of command substitutions in order to save value returned from function.

Since in this puzzle and my solution there is a need to do a lot of loops, I decided to do few dirty hacks in order to get better performance.

1. Do not use function to get absolute value `abs()`. In calculating of distance, you can swap arguments in a way that you always subtract lower number from higher and there is no need to use `abs()`.

## Finite points

There is assumption, that any point, that is located on edge of X or Y axis, specified by finding MIN and MAX X,Y values will be infinite, because areas past that cannot be closer to any other point.

Therefore we can operate out brute force solution restricted on rectangle with coordinates `x_min`, `x_max`, `y_min`, `y_max`.

## Solution - Part A

Bash script:

```bash
./chronal-coordinates-a.sh input.txt
```

## Solution - Part B

Bash Script:

```bash
./chronal-coordinates-b.sh input.txt
```
