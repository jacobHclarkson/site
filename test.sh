# The bug
ARR_A=( "A" "B" )
ARR_B=( "C" "D" )
ARR_AB_1=("${ARR_A[@]} ${ARR_B[@]}")
echo "${ARR_AB_1[0]}"
echo "${ARR_AB_1[1]}"
echo "${ARR_AB_1[2]}"
echo "${ARR_AB_1[3]}"

echo "--------------"

# What is acually going on?
ARR_A=( "A" "B" )
ARR_B=( "C" "D" )
ARR_AB_1=("${ARR_A[@]} ${ARR_B[@]}")

IFS="|"

echo "${ARR_AB_1[*]}"

echo "--------------"

# The solution
ARR_A=( "A" "B" )
ARR_B=( "C" "D" )
ARR_AB_2=("${ARR_A[@]}" "${ARR_B[@]}")

echo "${ARR_AB_2[*]}"

echo "${ARR_AB_2[0]}"
echo "${ARR_AB_2[1]}"
echo "${ARR_AB_2[2]}"
echo "${ARR_AB_2[3]}"
