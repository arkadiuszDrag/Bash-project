#!/bin/bash
if [ $# == 4 ]
then
    if [ -d "$4" ]
    then
        cd $4
    else
        echo Niepoprawna nazwa podanego katalogu jako argument 4 1>&2
    fi
elif [ $# != 3 ]
then   
    echo Niepoprawna liczba argumentow 2>&1
    exit -1
fi

if ! [[ "$(date '+%Y-%m-%d' -d $1)" = "$1" ]]
then 
    echo Zly format daty podanej jako arg1 1>&2
    exit -2
fi

if ! [[ "$(date '+%Y-%m-%d' -d $2)" = "$2" ]]
then
    echo Zly format daty podanej jako arg2 1>&2
    exit -2
fi

YearLess=$(echo $1 | cut -d"-" -f 1)
YearBigger=$(echo $2 | cut -d"-" -f 1)

MonthLess=$(echo $1 | cut -d"-" -f 2)
MonthBigger=$(echo $2 | cut -d"-" -f 2)

DayLess=$(echo $1 | cut -d"-" -f 3)
DayBigger=$(echo $2 | cut -d"-" -f 3)

srednia=0
i=0
sum=0
min=0
max=0

echo Proces w toku, prosze czekac...
for Y in *
do
#jezeli nie podamy katalogu z danymi, moga pojawic sie bledy - skrypt nie bedzie wiedziec, co jest w biezacym
if (( "$YearLess" <= "$Y" && "$YearBigger" >= "$Y" ))
then

    cd $Y
        for M in *
        do
        if (( "$MonthLess" <= "$M" && "$MonthBigger" >= "$M" ))
        then

            if [[ -z "$(ls -A $M )" ]]
            then
                continue
            fi

            cd $M
           
            for station in * 
            do
            
                cd "$station"
                for f in *
                do
                
                PolutionName=$(echo $f | cut -f2 -d"-")
                
                    if (( "$DayLess" <= "${f:0:2}" && "$DayBigger" >= "${f:0:2}" )) && [[ "$PolutionName" == "$3" ]]
                    then
            
                    #"${f#*-}" #usuwa sie %delimiter*, tak usunie poczatek i bedziemy miec to co po -

                        while read -r line
                        do
                            if (( $(bc <<< "$min>$line") || $(bc <<< "$min==0") ))
                            then
                                min=$line
                            fi

                            if (( $(bc <<< "$max<$line") ))
                            then 
                                max=$line
                            fi

                            sum=$(bc <<< "$sum+$line")
                            (( i++ ))
                        done<"$f"
                       
                    fi
                done  2>/dev/null
                cd .. > /dev/null
            done
            cd .. > /dev/null
        fi
        done
    cd .. > /dev/null
fi
done

if (( $i==0 ))
then
    echo Nie znaleziono pomiarow z danego zakresu o podanym zanieczyszczeniu.
    exit 2
else
    srednia=$(bc <<< "$sum/$i")
    
     if (( $(bc <<< "$srednia<1") ))
    then
        srednia=0$srednia
    fi

    if (( $(bc <<< "$max<1") ))
    then
         max=0$max
    fi
    
     if (( $(bc <<< "$min<1") ))
    then
       min=0$min
    fi
    echo -e $min'\t'$srednia'\t'$max #-e obsluguje znaki specjalne
fi
