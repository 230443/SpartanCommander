#!/bin/bash
ls -la | awk '
BEGIN {
	NR=0
	n=1
	x=1
	user=ENVIRON["USER"]
	split (system("groups"),groups," ")
	system("clear")

}
NR>1{
	type[n]=substr($0,1,1)
	name[n]=$9
	permissions=substr($1,2,9)
	printf "% 3s\t%s " ,n,permissions
	if($3 == user) printf substr($1,2,3)
	else {
		for (group in groups){
			if($3 == group) {
				printf substr($1,5,3)
				break
			}
		}
		printf substr($1,8,3) 
	}			
	printf " % 10s %1s\t%s\n", $5, type[n], $9
	n++
}
END {
	print "End"
	#system
}
'

exit 0
