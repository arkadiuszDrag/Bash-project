#!/bin/bash

if [ $# == 2 ] || [ $# == 3 ]
then
    if [ ! -d "$2" ]
    then
        mkdir "$2"
    fi
else
	echo Niepoprawna liczba argumentow 1>&2
	exit -1
fi


#liczba wierszy naglowka - domyslnie 3
header_lines="${3:-3}"

#pomijamy n linijek naglowkowych i robimy zmodyfikowane dane tylko z datami
sed -e "1,$header_lines"'d' $1 > zmodyfikowane_dane

head -n 1 $1 | cut -d ";" -f 2- > station
sed 's/;/\n/g' station > stationNew
rm station

head -n 2 $1 | tail -n 1 | cut -d ";" -f2- > polution
sed 's/;/\n/g' polution > polutionNew
rm polution

cut -f 1 -d ";" $1 | cut -f 1 -d" " > dates
sed -e "1,$header_lines"'d' dates > datesNew
rm dates


echo Proces w toku, prosze czekac...
while read -r line
do
	
	zmienna=$(echo $line | cut -f 1 -d ";" | cut -f 1 -d" " | cut -f 1 -d "-")
	if [ ! -d "$2/$zmienna" ]
	then
		mkdir "$2/$zmienna"
	fi

	zmienna2=$(echo $line | cut -f 1 -d ";" | cut -f 1 -d" " | cut -f 2 -d "-")
	if [ ! -d "$2/$zmienna/$zmienna2" ]
	then
		mkdir "$2/$zmienna/$zmienna2"
	fi

	licznik=2
	while read -r line1
	do
		pomiar=$(echo $line | cut -f $licznik -d ";")
			if [[ $pomiar ]]
			then
		
				if [[ ! "$pomiar" == " " ]]
				then
					if [ ! -d "$2/$zmienna/$zmienna2/$line1" ]
					then
						mkdir "$2/$zmienna/$zmienna2/$line1"
					fi

				dayStation=$(echo $line | cut -f 1 -d ";" | cut -f 1 -d" " | cut -f 3 -d "-")
				((licznik2=licznik-1))

				pollution=$(head -n $licznik2 polutionNew | tail -n 1)
				echo $line | cut -f $licznik -d ";" > plik
				
				if [ ! -e "$2/$zmienna/$zmienna2/$line1/$dayStation-$pollution" ]
				then
					touch "$2/$zmienna/$zmienna2/$line1/$dayStation-$pollution"
					
				fi
				
				cat plik >> "$2/$zmienna/$zmienna2/$line1/$dayStation-$pollution"	
								
				fi
			fi
	
	((licznik=licznik+1))
	done < stationNew

done < zmodyfikowane_dane






















