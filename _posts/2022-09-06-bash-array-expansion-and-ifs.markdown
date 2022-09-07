---
layout: post
title:  "Bash: Expansion and IFS"
date:   2022-09-06 10:00:00 +0200
categories: bash tips-and-tricks
---

I created an interesting bash bug the other day. I thought it was bewildering
enough to warrant investigation.

## The Problem

Given two arrays:
```bash
# Set up some array variables
ARR_A=( "A" "B" )
ARR_B=( "C" "D" )
```

We attempt to concatenate them:
```bash
# Concatenate the arrays
ARR_AB=( "${ARR_A[@]} ${ARR_B[@]}" )
```

Now check the contents of the the resulting array:
```bash
# Print each element in the result on a new line
for elem in "${ARR_AB[@]}"
do
    echo $elem
done
```

I expected `ARR_AB` to be an array of 4 elements. `A` and `B` from `ARR_A` and
`B` and `C` from `ARR_B`. Printing them out, then, as above, should produce
this:

```
A
B
C
D
```

But this is bash. And bash is mysterious. And we get this:


```
A
B C
D
```

The first element is `A` from the first array. Fine. The last element is `D`
from the second array. Also fine. But the middle element consists of elements of
both of the input arrays. What?!

## What is happening?

To investigate this, we can use two tricks:
- We can manipulate the Internal Field Separator (IFS)
- We can use the double-quoted `*` expansion to let us see where the IFS
  characters are being placed.
  
# The IFS
TODO what is the IFS

# @ and *

# Back to our problem

```bash
# Set up some array variables
ARR_A=( "A" "B" )
ARR_B=( "C" "D" )

# "Concatenate" the arrays
ARR_AB=( "${ARR_A[@]} ${ARR_B[@]}" )

# Set IFS and take a look
IFS="|"
echo "${ARR_AB[*]}"
```
```
A|B C|D
```

## The Solution(s)

# Version 1

```bash
# Set up some array variables
ARR_A=( "A" "B" )
ARR_B=( "C" "D" )

# Concatenate the arrays (for real)
ARR_AB=( "${ARR_A[@]}" "${ARR_B[@]}" )

# Set IFS and take a look
IFS="|"
echo "${ARR_AB[*]}"

# Print each element in the result on a new line
for elem in "${ARR_AB[@]}"
do
    echo $elem
done
```

```
A|B|C|D
A
B
C
D
```

# Version 2

```bash
# Set up some array variables
ARR_A=( "A" "B" )
ARR_B=( "C" "D" )

# Concatenate the arrays (for real)
ARR_AB=( ${ARR_A[@]} ${ARR_B[@]} )

# Set IFS and take a look
IFS="|"
echo "${ARR_AB[*]}"

# Print each element in the result on a new line
for elem in "${ARR_AB[@]}"
do
    echo $elem
done
```

```
A|B|C|D
A
B
C
D
```
