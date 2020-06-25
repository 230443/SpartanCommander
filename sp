#!/bin/bash
: '
Spartan Commander - list directory content
usage: sp [FILE]

commands
	+	scroll down
	-	scroll up
	^	jump to the beginning of the list
	$	jump to the end of the list
	q	quit
	<file no.>	execute program or switch directory
AUTHOR
	Daniel Baraniak
'	

#lines: numer of lines that can be used for printing list
lines=$(($(tput lines)-2))
groups=$(groups)


createList()
{
	#x: variable used in printing the list
	x=1
	cd $1
	list=`ls -la |tail -n+2| awk -v grp="$groups" -v user=$USER '
	BEGIN {split (grp,groups," ")}
	{
		printf "% 3s\t%s " ,NR, substr($1,2,9)
		if($3 == user) printf substr($1,2,3)
		else {
			for (i in groups){
				if($4 == groups[i]) {
					printf substr($1,5,3)
					b=1
					break
				}

			}
			if(b!=1)	printf substr($1,8,3) 
			else		b=0
		}			
		printf " % 8s %1s   %s\n", $5, substr($0,1,1), $9
	}
	'`
	len=$(echo "$list" | awk 'END{printf $1}')
	diff=$(($len - $lines))	
	return 0
}

ask()
{
	while :
	do
		read -sn 1
		case $REPLY in

		"+")	[ $diff -gt 0 ] && [ $x -le $diff ] && ((x++)) && show
			;;
		"-")	[ $x -gt 1 ] && ((x--)) && show
			;;
		"q")	exit 0
			;;
		"$")	[ $diff -gt 0 ] && x=$(( $diff + 1)) && show
			;;
		"^")	x=1 && show
			;;
		[0-9])	
			# continue reading
			echo -n $REPLY
			read num
			num=$REPLY$num
			# get filename
			name=$(echo "$list" | awk -v num=$num 'NR==num {printf $6}')
			# change directory or execute program
			[ -d $name ] && createList $name  || [ -x $name ] && $(./$name)
			show
			;;
		esac
	done
}

show()
{
	clear
	echo $PWD
	echo "$list" | tail -n +$x | head -n $lines
}

#### MAIN  #####

[ ! -d "$1" ] && createList $PWD || createList $1
show
ask

exit 0
