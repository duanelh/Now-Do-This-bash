#!/bin/bash

## License: GPL, http://www.gnu.org/copyleft/gpl.html
## This is a command line implementation of the 'Now Do This' http://nowdothis.com/ website
## The idea is respectfully borrowed from http://nowdothis.com

#################################################
#### Settings ###################################
#################################################

## Where you wish to store your 'Now Do This' file
NDT="~/Documents/Todo/nowdothis.txt"
ARCHIVE="~/Documents/Todo/nowdothis.txt.old"

## Location of your todo.txt file
TODOTXT="~/Documents/Todo/todo.txt"

## Your text editor of choice
EDITOR="gedit"

## Your todotxt command
TODOCMD="~/bin/todo.sh"

## Atom feed of your desired Remember the Milk list
FEED=""

#############################################
#### Script do not change anything below ####
#############################################

ITEM=$(head -n1 $NDT)
NEW=$2

FIRST ()
{
    ## Check to see if there is anything in the list
    if [ $(wc -c $NDT | awk '{print $1}') -lt 2 ]; then
        echo -e "\nTake a break, nothing to do"
   else
        echo -e "\nNow do this:"
        echo "$(head -n1 $NDT)"
        echo "----------"
        echo "+$(wc -l $NDT | awk '{print $1-1}') more"
    fi
}

REMOVE ()
{
    ## Check if the current item is imported the todo.txt file
    ## Mark as done with the todo.sh file, and remove from the NDT file
    if [ "$(cat $NDT | head -n1 | awk '{print $1}')" = "td" ]; then
        $TODOCMD do $(cat $NDT | head -n1 | awk '{print $3}')
        sed -i 1d $NDT
    ## Check to see if the item was imported from RTM
    elif [ "$(cat $NDT | head -n1 | awk '{print $1}')" = "RTM" ]; then
        echo "****"
        echo "Remove $ITEM from Remember the Milk"
        echo "****"
        sed -i 1d $NDT
    else
        sed -i 1d $NDT
    fi
}

ADD ()
{
    echo $NEW >> $NDT
    echo "$NEW added to:"
    echo $NDT
}

FULLLIST ()
{
    cat $NDT
    echo "----------"
    echo "$(wc -l $NDT | awk '{print $1}') total"
}

EDIT ()
{
#    vim -c start\! $NDT
    $EDITOR $NDT
    echo "Done editing $NDT"
}

LATER ()
{
    echo "'$(head -n1 $NDT)' moved to the bottom of the list"
    echo $(head -n1 $NDT) >> $NDT
    sed -i 1d $NDT
}

HELP ()
{
    echo -e "list OR ls OR l"
    echo -e "\tList first item"
    echo -e "full OR fl OR fls"
    echo -e "\tSee your full list"
    echo -e "next n"
    echo -e "\tDisplay the next item"
    echo -e "add OR a ["New item"]"
    echo -e "\tAdds an item to your list"
    echo -e "later"
    echo -e "\tMoves the top item to the bottom"
    echo -e "edit e"
    echo -e "\tEdit your list"
    echo -e "rtm"
    echo -e "\tImport your Remember the Milk list"
    echo -e "todo"
    echo -e "\tImport all items from your todo.txt file that are marked with '@NDT'"
}

CLEANUP ()
{
    rm /tmp/nowdothis.txt
    if [ -f /tmp/ndt ]; then
        rm /tmp/ndt
    fi
}

CLEANLIST ()
{
    ## Remove any blank lines
    cat $NDT | grep . > /tmp/nowdothis.txt
    cat /tmp/nowdothis.txt > $NDT
}

RTM ()
{
    ## Import items from your Remember the Milk list
    curl $FEED | sed 's:>:>\
:g' | grep -E '(</title>)' | sed 's/T\([0-9]*\):\([0-9]*\):\([0-9]*\)Z//' | tail --lines=+2 | sed -e 's/<\/title>//' -e 's/<\/dc:date>//' | sed -e 's/^/RTM - /' >> $NDT
}

TODO ()
{
    ## Import items from todo.txt
    $TODOCMD ls | grep @NDT | sed 's:^a*:td\ \-\ :' | sort >> $NDT
}

##Make sure the files are there
touch $NDT
touch $ARCHIVE

CLEANLIST

case $1 in
    "list" | "l" | "ls" )
        FIRST
        ;;
    "full" | "fls" | "fl" )
        FULLLIST
        ;;
    "next" | "n" )
        echo "$ITEM archived to:"
        echo "$ARCHIVE"
        echo "$(date +%FT%R) $ITEM" >> $ARCHIVE
        REMOVE
        FIRST
        ;;
    "add" | "a" )
        ADD
        FIRST
        ;;
    "edit" | "e" )
        EDIT
        FIRST
        ;;
    "rtm" )
        RTM
        ;;
    "todo" )
        TODO
        ;;
    "later" )
        LATER
        FIRST
        ;;
    * )
        HELP
        ;;
esac
