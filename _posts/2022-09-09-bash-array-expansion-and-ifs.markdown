---
layout: post
title:  "Bash: Expansion and IFS"
date:   2022-09-08 15:00:00 +0200
categories: tips-and-tricks bash
---

I created an interesting bash bug the other day. I thought it was bewildering
enough to warrant investigation.

*Disclaimer: I am not a registered bash practitioner. This post is more about intuition than fact. Your mileage may vary.*

## The Problem

Given two arrays:
```bash
# Set up some array variables
ARR_A=( "A" "B" )
ARR_B=( "C" "D" )
```

We attempt to concatenate them (seems plausible):
```bash
# Concatenate the arrays
ARR_AB=( "${ARR_A[@]} ${ARR_B[@]}" )
```

Now check the contents of the the resulting array:
```bash
# Print each element in the result
echo "${ARR_AB[0]}"
echo "${ARR_AB[1]}"
echo "${ARR_AB[2]}"
echo "${ARR_AB[3]}"
```

I expected `ARR_AB` to be an array of 4 elements. `'A'` and `'B'` from `ARR_A`
and `'B'` and `'C'` from `ARR_B`. Printing them out, then, as above, should
produce this:

```
A
B
C
D
```

But this is bash. And bash is dark, and mysterious. So, we get this:


```
A
B C
D

```
Somehow, there are only three elements, the middle of which contains data from both input arrays. What?!

## What is happening?

To investigate this, we can use two tricks:
- We can manipulate the Internal Field Separator (IFS)
- We can use the double-quoted `*` expansion to let us see where the IFS
  characters are being placed.
  
# The IFS, @, and *
The IFS is [a variable which defines the character or characters used to
separate a pattern into tokens][wikipedia-ifs]. This token is what delimits the
elements in a bash array.

By default, the IFS is set to \<space\>\<tab\>\<newline\>, but we can change it
to a non-whitespace character just by assigning to the IFS variable.

`@` and `*` are both special characters that do parameter expansion. [They
behave differently when used within and without double-quotes][bash-manual]. Of
particular use to us now is that `*`, when it occurs in double quotes, "expands
to a single word with the value of each parameter separated by the first
character of the IFS special variable". This means that we can print a representation and see the IFS characters. For example:

```bash
IFS="|"
ARR=( "A" "B" )
echo "${ARR[@]}"
echo "${ARR[*]}"
```

Produces:

```
A B
A|B
```

The second line of output shows the contents of our array as a single "word"
with each element separated by the first character of the IFS, which in this
case, is just `|`.

# Back to our problem

Here, we again specify `|` as the IFS, and we print out the result of the `*` expansion:

```bash
# Set up some array variables
ARR_A=( "A" "B" )
ARR_B=( "C" "D" )

# "Concatenate" the arrays
ARR_AB=( "${ARR_A[@]} ${ARR_B[@]}" )

# Set IFS and take a look
IFS="|"
echo "${ARR_AB[@]}"
echo "${ARR_AB[*]}"
```
The result:
```
A B C D
A|B C|D
```

Aha! We are missing an IFS between `'B'` and `'C'`. `ARR_AB` is therefore being
interpreted as "an array of three elements, the second of which is `'B C'`".

This happens because, before expansion, the double-quote surrounded `${ARR_A[@]}
${ARR_B[@]}` is a single element. The two expressions inside the string are then
expanded, and the resulting IFS characters effectively break the original
element up into three separate elements.

## The Solution

Quote each expansion in the `ARR_AB` declaration separately (or don't quote at
all if you don't need to). Before expansion, there are already two elements
(with an IFS between them). The left and right elements both expand into two
elements, as expected.

```bash
# Set up some array variables
ARR_A=( "A" "B" )
ARR_B=( "C" "D" )

# Concatenate the arrays (for real)
ARR_AB=( "${ARR_A[@]}" "${ARR_B[@]}" )
# ARR_AB=( ${ARR_A[@]} ${ARR_B[@]} ) # also fine

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

[wikipedia-ifs]: https://en.wikipedia.org/wiki/Input_Field_Separators
[bash-manual]: https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html
