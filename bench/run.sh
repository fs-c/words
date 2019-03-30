cd ..

START=$(date +%s.%N)

./words --content "./bench/content/" --public "./bench/public"

END=$(date +%s.%N)
DIFF=$( echo "scale=3; (${END} - ${START})*1000/1" | bc )
echo "${DIFF}ms"

cd bench