#!/bin/bash

#Relays from Kamami NetTemp Board https://kamami.pl/kamod-kamami/559377-nettemp-pi-hat-modul-nettemp-dla-komputera-raspberry-pi.html
    relayA=23
    relayB=21
    relayC=22
    relayD=24

#set output mode for pin connected to relays

                for pin in 21 22 23 24
                do
                    gpio mode $pin out
                done

    night_hour=20
    day_hour=6
    current_hour=`date +%k`
    day_temp_set=23.0
    night_temp_set=21.0
    temp_histeresis=0.1

                if (( $(echo "$current_hour < $day_hour" |bc -l)  )) || (( $(echo "$current_hour > $night_hour" |bc -l)  ))
                then
                    temp_set=$night_temp_set
                    echo "Jest noc"
                    echo "Temperatura zadana na godziny nocne: $temp_set"
                else
                    temp_set=$day_temp_set
                    echo "Jest dzień"
                    echo "Temperatura zadana na godziny dzienne: $temp_set"
                fi

    temp_measured=`sqlite3  /var/www/nettemp/db/28-000004a1aad1.sql  "SELECT value FROM def ORDER BY time DESC LIMIT 1;"`
    relayA_status=`gpio read $relayA`

                if (( $(echo "$temp_measured > $temp_set+$temp_histeresis" |bc -l) ))
                then
                    if  (( $(echo "$relayA_status > 0 " |bc -l) ))
                    then
                    echo "Temparatura w łazience wynosi $temp_measured i jest wyższa od temperatury zadanej $temp_set"
                    echo "Ogrzewanie jest już wyłączone, nic nie robię"
                    else
                    echo "Temparatura w łazience wynosi $temp_measured i jest wyższa od temperatury zadanej $temp_set"
                    echo "Wyłączam ogrzewanie"
                    gpio write $relayA 1
                    fi
                else
                    if  (( $(echo "$relayA_status < 1 " |bc -l) ))
                    then
                    echo "Temparatura w łazience wynosi $temp_measured i jest niższa od temperatury zadanej $temp_set"
                    echo "Ogrzewanie jest już włączone, nic nie robię"
                    else
                    echo "Temparatura w łazience wynosi $temp_measured i jest niższa od temperatury zadanej $temp_set"
                    echo "Włączam ogrzewanie"
                    gpio write $relayA 0
                    fi
                fi
