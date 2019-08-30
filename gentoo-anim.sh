#!/bin/bash

# have an ascii starfield  a really half ass one i wrote while drunk.  it looked good
# while i was drinking, now i'm sober and it has problems.  have at.
display_center(){
    local x
    local y
    text="$*"
    x=$(( ($(tput cols) - ${#text}) / 2))
    echo -ne "\E[6n";read -sdR y; y=$(echo -ne "${y#*[}" | cut -d';' -f1)
    echo -ne "\033[${y};${x}f$*"
}

function msg_anim() {
    local title
    local subtitle
    local start
    local duration
    local max_duration
    
    if [[ "$1x" != "x" ]]; then
        title="$1"
    fi
    if [[ "$2x" != "x" ]]; then
        subtitle="$2"
    fi
    if [[ "$3x" != "x" ]]; then
        max_duration="$3"
    fi
    echo -ne "\\033[2J"

    # 2D Starfield Script by Me!
    
    # dicks
    tput civis
    RANDOM=$$$(date +%s)
    STARCHARS='.+*X'
    for i in {1..50}; do
        ranged_random=$RANDOM
        let "ranged_random %= $(tput cols)"
        starx[i]=$ranged_random
        ranged_random=$RANDOM
        let "ranged_random %= $(tput lines)"
        stary[i]=$ranged_random
        ranged_random=$RANDOM
        let "ranged_random = ranged_random % 4"
        starspd[i]=$(($ranged_random+1))
        starchar[i]=${STARCHARS:$((${starspd[i]}-1)):1}
        ranged_random=$RANDOM
        let "ranged_random = ranged_random % 7"
        starcolor[i]=$(($ranged_random+30))
        if [ ${starspd[i]} -gt "2" ]; then
            starcolor[i]=$((${starcolor[i]}+60))
        fi
    done
    
    # draw loop with duration
    start=$SECONDS
    duration=$(( SECONDS - start ))
    while [ $duration -lt "$max_duration" ]; do
        for i in {1..50}; do
            if test -z ${starx[i]}; then
                # initialize new star
                starx[i]=$(tput cols)
                ranged_random=$RANDOM
                let "ranged_random %= $(tput lines)"
                stary[i]=$ranged_random
                ranged_random=$RANDOM
                let "ranged_random = ranged_random % 4"
                starspd[i]=$(($ranged_random+1))
                starchar[i]=${STARCHARS:$((${starspd[i]}-1)):1}
                ranged_random=$RANDOM
                let "ranged_random = ranged_random % 7"
                starcolor[i]=$(($ranged_random+30))
                if [ ${starspd[i]} -gt "3" ]; then
                    starcolor[i]=$((${starcolor[i]}+60))
                fi
            else
                # erase the old star
                echo -ne "\033[${stary[i]};${starx[i]}f "
                starx[i]=$((${starx[i]}-${starspd[i]}))
                if [ ${starx[i]} -lt "0" ]; then
                    starx[i]=
                    stary[i]=
                    starspd[i]=
                else
                    # draw the new star
                    echo -ne "\033[${stary[i]};${starx[i]}f\e[${starcolor[i]}m${starchar[i]}"               
                fi
            fi
        done
        
        echo -ne "\033[10;1f\e[94m"
        display_center "$title"
        echo -ne "\033[13;1f\e[93m"
        display_center "$subtitle"
        
        read -t 0.01 -N 1 input
        if [[ $input = "q" ]] || [[ $input = "Q" ]]; then
            echo
            break
        fi
        duration=$(( SECONDS - start ))
    done
    
    # destroy
    echo -ne "\e[39m\033[2J\033[1;1f"
    tput cnorm
}