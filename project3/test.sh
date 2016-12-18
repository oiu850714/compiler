for x in $(ls testcases/testcases/correct/*.cm);
do
	echo "${x}"
	./parser "${x}"  2>&1
done

echo "correct down!!!"
