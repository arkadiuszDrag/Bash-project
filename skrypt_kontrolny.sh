#!/bin/bash

if [ ! $# -eq 2 ]
then 
    echo Za malo argumentow. Sprobuj ponownie. 1>&2
    exit 1
fi

if [ -d $1 ]
then
    cd $1
else
    echo Podany argument 1 nie jest katalogiem. 1>&2
fi

tree -L 2 --noreport
echo Lista pustych katalogow: 

for Y in *
do

cd $Y
    for M in *
    do
   
        if [[ -z "$(ls -A $M )" ]]
        then
           echo Miesiac: $M jest pusty 1>&2
        fi

    done
cd - > /dev/null
done

echo Lista plikow o innej ilosci pomiarow: 
for Y in *
do
cd $Y
    for M in *
    do
        if [[ -z "$(ls -A $M )" ]]
        then
            continue
        fi

        cd $M

        for S in * 
        do
            cd "$S"
            for f in *
            do
                if [ ! $2 -eq $( sed '/^\s*$/d' "$f" | wc -l) ]
                then
                    echo Plik ma inna ilosc pomiarow: $1/$Y/$M/$S "->" $( echo "$f" | wc -l) pomiarow. 1>&2
                fi
            done
            cd .. > /dev/null
        done

        cd .. > /dev/null
    done
cd .. > /dev/null
done
