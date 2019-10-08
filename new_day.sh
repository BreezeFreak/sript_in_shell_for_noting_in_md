#!/bin/bash

# noticing that double quotes were no needed for string const, but execution
HOME_DIR=~/notes/work/notes_shanqu
# HOME_DIR=/home/joe/notes/work/notes_shanqu/working\ notes

NOTES_DIR=$HOME_DIR/working\ notes

LAST_WEEK=$(tree "$HOME_DIR" | grep -P "week \d+" | sed "s/.*week \([0-9]*\).*/\1/g" | sort -rn -t " " -k 1 | head -1)

# quick pushing, especially Firday
if [ $1 ] && [ $1 = "push" ]; then
    if [ ! $(date +%w) = 5 ]; then
        read -p "Tomorrow is not weekend, are you sure to continue pushing? [y/n] " input
        case $input in
                ""|[yY]*)
                        # pushing the notes but this script stays
                        cd "$HOME_DIR"
                        cp ~/.zshrc ~/.bashrc "$HOME_DIR"/shell/
                        git add "$HOME_DIR" 
                        git commit -m "week $WORKING_WEEK"
                        git push

                        cd "$HOME_DIR"/tools
                        if [ -z $(git status | grep "working directory clean") ]; then
                            git add .

                            read -p "note tool has been modified, enter the commit message: " msg
                            if [ -z "$msg" ]; then
                                msg="NOTHING"
                            fi

                            git commit -m "$msg"
                            git push
                        fi
                        ;;
                # [nN]*)
                #         exit
                #         ;;
                # *)
                #         exit
                #         ;;
        esac
    else
        cp ~/.zshrc ~/.bashrc "$HOME_DIR"/shell/
        git add "$HOME_DIR" 
        git commit -m "week $WORKING_WEEK"
        git push
    fi

    # read -n1 -p "Do you want to update the tv feed? [y/n/q] " ynq
    # echo $ynq

    exit 0
fi

# check if there is already a markdown file, which named by date of today, exists
TEMP=$(tree "$NOTES_DIR" | grep "$(date +%m-%d).md")
LAST_DAY=$(tree "$NOTES_DIR" | grep "$(date +%m-%d -d "-1day").md")
# if [ $? = 0 ]; then

WEEK_DIR=$NOTES_DIR/week\ $LAST_WEEK

if [ ! -z "$TEMP" ]; then
     echo "Note file exist, start working!"
     notify-send "Working Note" "Note file exist, start working!"

    code -r "$WEEK_DIR"/$(date +%m-%d).md


    sleep 1
    guake toggle

     exit 0
fi

# alias gdo='cp ~/.zshrc ~/.bashrc /home/joe/notes/work/notes_shanqu/shell/ && git add /home/joe/notes/work/notes_shanqu && git commit -m "week $WORKING_WEEK" && git push'

# echo "$(date +%m-%d -d "-$(expr $(date +%w) - 1 )day").md"
# Trying to check if new week begin with not monday, which will cause another problem, probably.
# Turn to another angle... if the name of the latest file is not the yesterday, then treating today as a day of a new week, then start a new week

# when it's Monday
# if [ $(date +%w) = 1 ]; then
# when yesterday did not a work day
# FIXME: what if there was a sick day break
if [ -z "$LAST_DAY" ]; then

    WEEK_DIR=$NOTES_DIR/week\ $(expr $LAST_WEEK + 1)

    # mkdir "$WEEK_DIR" && touch "$WEEK_DIR"/$(date +%m-%d).md
    mkdir "$WEEK_DIR" && cp "$HOME_DIR"/Assignment.md  "$WEEK_DIR"/$(date +%m-%d).md

    echo "It's week $(expr $LAST_WEEK + 1), md file is ready, clock is tiking, chup chup!"
     notify-send "Working Note" "It's week $(expr $LAST_WEEK + 1), md file is ready, clock is tiking, chup chup!"

elif [ ! -f "$WEEK_DIR"/$(date +%m-%d).md ]; then

    WEEK_DIR=$NOTES_DIR/week\ $LAST_WEEK

    # touch "$WEEK_DIR"/$(date +%m-%d).md
    cp "$HOME_DIR"/Assignment.md "$WEEK_DIR"/$(date +%m-%d).md

    echo "$LAST_WEEK is on going, it's a brand new day!"
     notify-send "Working Note"  "$LAST_WEEK is on going, it's a brand new day!"
else 
    echo "Every thing is perfect, just do your job!"
     notify-send "Working Note"  "Every thing is perfect, just do your job!"
fi

code -r "$WEEK_DIR"/$(date +%m-%d).md

sleep 1
guake toggle
# TODO: auto add ./TODO.md into every day's new md file