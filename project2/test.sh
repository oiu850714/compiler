for x in $(ls testcases/testcases/correct/*.cm);
do
	echo "${x}"
	./parser "${x}"
done

echo "correct down!!!"

for x in $(ls testcases/testcases/wrong/*.cm);
do
	echo "${x}"
	./parser "${x}"
done
