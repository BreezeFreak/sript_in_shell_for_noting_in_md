#!/bin/bash

# noticing that double quotes were no needed for string const, but execution
HOME_DIR=~/notes/work/notes_shanqu

# other dirs
PROJECT_DIR=~/workspace/game/game-wiki
PROJECT_GIN_UTILS_DIR=$PROJECT_DIR/src/v1d0/gin-utils
PROJECT_GIN_UTILS_CONFIG=$PROJECT_DIR/.git/modules/src/v1d0/gin-utils/config
SCRIPT_DIR=~/temp/off_work_timmer
# HOME_DIR=/home/joe/notes/work/notes_shanqu/working\ notes

NOTES_DIR=$HOME_DIR/working\ notes

cd "$NOTES_DIR"
grep --exclude=TODOS.md -rEI -n "TODO|FIXME" . 2>/dev/null | sort -n -t ' ' -k 2 | awk '{split($0,a,":");split($2,b,":"); print "["a[3]"]("$1"%20"b[1]"#L"a[2]")\n"}' >| TODOS.md

LAST_WEEK=$(tree "$HOME_DIR" | grep -P "week \d+" | sed "s/.*week \([0-9]*\).*/\1/g" | sort -rn -t " " -k 1 | head -1)

# pushing the notes
push_note() {
    echo "[pushing notes ...]"
    cd "$HOME_DIR"
    cp ~/.zshrc ~/.bashrc "$HOME_DIR"/shell/
    git add "$HOME_DIR" 
    git commit -m "week $LAST_WEEK"
    git push
}

# pushing this script
push_script() {
    echo "[pushing the script it self ...]"
    cd "$HOME_DIR"/tools
    if [ -z $(git status | grep "working directory clean") ]; then
        git add .

        read -p "Note tool has been modified, enter the commit message: " msg
        if [ -z "$msg" ]; then
            msg="NOTHING"
        fi
        # TODO:
        # https://stackoverflow.com/a/5082055/12254646
        # msg="$(cat new_day.sh | grep "COMMIT:" | awk '{ s = ""; for (i = 3; i <= NF; i++) s = s $i " "; print s }' | tail -1)"

        git commit -m "$msg"
        git push
    fi
}

push_gin_utils() {
    echo "[pushing gin-utils...]"
    sed -i 's/gitlab.ghzs.com:oam/github.com:BreezeFreak/g' "$PROJECT_GIN_UTILS_CONFIG" >> "$PROJECT_GIN_UTILS_CONFIG"
    cd "$PROJECT_GIN_UTILS_DIR"
    git push
    sed -i 's/github.com:BreezeFreak/gitlab.ghzs.com:oam/g' "$PROJECT_GIN_UTILS_CONFIG" >> "$PROJECT_GIN_UTILS_CONFIG"
}

push_off_work_timmer() {
    echo "[pushing off_work_timmer.sh ...]"
    cd "$SCRIPT_DIR"
    git add .
    git commit -m "update"
    git push
    cd "-"
}

push_together() {
    push_script
    push_note
    push_gin_utils
    push_off_work_timmer
}

# quick pushing, especially Firday
if [ $1 ] && [ $1 = "push" ]; then
    if [ ! $(date +%w) = 5 ]; then
        read -p "Tomorrow is not weekend, are you sure to continue pushing? [y/n] " input
        case $input in
                ""|[yY]*)
                        push_together
                        ;;
                # [nN]*)
                #         exit
                #         ;;
                # *)
                #         exit
                #         ;;
        esac
    else
        push_together
    fi
    exit 0
fi

# testing
if [ $1 ] && [ $1 = "test" ]; then
    cd "$HOME_DIR"/tools
    a= $(cat new_day.sh | grep "COMMIT:" | awk '{ s = ""; for (i = 3; i <= NF; i++) s = s $i " "; print s }' | tail -1)
    echo $a
    sed -i "s/$a/NOTHING/g" new_day.sh

    exit 0
fi

WEEK_DIR=$NOTES_DIR/week\ $LAST_WEEK

end_of_script() {
    code -r "$WEEK_DIR"/$(date +%m-%d).md

    # sleep 1
    # guake toggle
    exit 0
}

new_week() {
    WEEK_DIR=$NOTES_DIR/week\ $(expr $LAST_WEEK + 1)

    # mkdir "$WEEK_DIR" && touch "$WEEK_DIR"/$(date +%m-%d).md
    mkdir "$WEEK_DIR" && cp "$HOME_DIR"/Assignment.md  "$WEEK_DIR"/$(date +%m-%d).md

    echo "It's week $(expr $LAST_WEEK + 1), md file is ready, clock is tiking, chup chup!"
    notify-send "Working Note" "It's week $(expr $LAST_WEEK + 1), md file is ready, clock is tiking, chup chup!"

    end_of_script
}

new_day() {
    WEEK_DIR=$NOTES_DIR/week\ $LAST_WEEK

    # touch "$WEEK_DIR"/$(date +%m-%d).md
    cp "$HOME_DIR"/Assignment.md "$WEEK_DIR"/$(date +%m-%d).md

    echo "$LAST_WEEK is on going, it's a brand new day!"
    notify-send "Working Note"  "$LAST_WEEK is on going, it's a brand new day!"

    end_of_script
}

# check if there is already a markdown file exists, which named by date of today
TEMP=$(tree "$NOTES_DIR" | grep "$(date +%m-%d).md")

if [ ! -z "$TEMP" ]; then
     echo "Note file exist, start working!"
     notify-send "Working Note" "Note file exist, start working!"
     
     end_of_script
fi

LAST_DAY=$(tree "$NOTES_DIR" | grep "$(date +%m-%d -d "-1day").md")
# if [ $? = 0 ]; then

if [ -z "$LAST_DAY" ]; then
    # when today is Monday
    if [ $(date +%w) != 1 ]; then
        # sick, or sth. or power dead yesterday
        read -p "Didn't work yesterday, is this a new week? [ENTER is YES and others to continue] " input
        if [ ! -z "$input" ]; then
            new_day
        fi
    fi
    # if last week is a empty folder
    # files=$(shopt -s nullglob dotglob; echo "$LAST_WEEK"/*)
    # if (( ${#files} ))
    # https://stackoverflow.com/a/20456797/12254646
    if find "$LAST_WEEK" -mindepth 1 -print -quit 2>/dev/null | grep -q .
    then
        new_day
    else 
        new_week
    fi
fi

if [ ! -f "$WEEK_DIR"/$(date +%m-%d).md ]; then
    new_day
else 
    echo "Every thing is perfect, just do your job!"
     notify-send "Working Note"  "Every thing is perfect, just do your job!"
fi

# TODO: everyday adding flag of UNDONE manually? so the next day i `note`, copy the UNDONE content to the new note

# ----- commit field
# COMMIT: add: 'commit field' && check if week folder exists
# COMMIT: add: 'commit field' && check if week folder exists
