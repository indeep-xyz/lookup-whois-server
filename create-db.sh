#!/bin/bash
#
# SUMMARY
#   create database of whois-servers by gTLD string
#   require 'gtld.list' at the same location as this script
#
# USAGE:
#   $ create-db.sh
#
#   write to ./whois-servers.csv
#   format (CSV)
#   -
#   [gTLD],[whois-server's address]
#
#   could not detect gTLD to <STDOUT>
#   format
#   -
#   [gTLD]
#

# - - - - - - - - - - - - - - - - - -
# functions

# = =
# push to file
#
# args
# $1 ... file path
# $2 ... string
function push() {

  local file="$1"
  local text="$2"
  local lock="${file}.~lock"

  while ! mkdir "$lock" 2> /dev/null;
  do
    sleep 1
  done

  echo "$text" >> "$file"
  rmdir "$lock"
}

# = =
# push routine
#
# args
# $1 ... gTLD string
# $2 ... database path for push
function push_routine() {

  local gtld="$1"
  local db="$2"
  local ws="`$BIN_LOOKUP $gtld`"

  # check return value
  if [ -n "$ws" ]; then

    # if not empty
    # - push to database file
    push "$db" "$gtld,$ws"
  else

    # if empty (lookup failure)
    # - echo
    echo $gtld
  fi
}

# = =
# get gTLD list
# if exists in database, excluding gTLD
#
# depend variables
# $GTLD_LIST      ... list for gTLD
# $GTLD_DENY_LIST ... deny list for gTLD
# $DB_MAIN        ... existing database made by this script
#
# echo
# line separated gTLD string
function get_list() {

  local gl="`cat "$GTLD_LIST"`"
  local db=

  # check database file
  if [ ! -f "$DB_MAIN" ]; then

    # if not exists, echo full
    echo -e "$gl"
  else

    # if exists
    # - echo non-existence gTLD string

    db="`cat "$DB_MAIN" "$GTLD_DENY_LIST" | sed 's/,.*$//'`"

    echo -e "$gl" | while read gtld;
    do
      if ! echo -e "$db" | grep -q "^$gtld"; then
        echo $gtld
      fi
    done
  fi
}

# = =
# create main
#
# depend variables
# $DB_MAIN    ... existing database made by this script
# $FLAG_FORCE ... option -f
#                 if setted, does not exclude by database's value
#
# echo
# line separated gTLD string
function create() {

  local db_temp="${DB_MAIN}.~temp"
  local gl="`get_list`"
  local -i gl_len=`echo -e "$gl" | wc -l | sed 's/^\([0-9]\+\).*/\1/'`
  local -i cnt=0
  local -i ch_used=0

  # remove old temporary
  rm "$db_temp" 2> /dev/null

  # if no list, exit
  [ $gl_len -lt 1 ] && exit 0

  # if exists old database, copy to temporary
  [ -f "$DB_MAIN" ] && cp $DB_MAIN $db_temp

  # main
  echo -e "$gl" | while read gtld;
  do

    push_routine $gtld "$db_temp" &
    let ch_used++

    if [ $ch_used -gt $CH_MAX ]; then
      wait
      let ch_used=0
    fi

    let cnt++

    if [ $cnt -ge $gl_len ]; then
      wait
    fi
  done

  # check temporary file
  if [ -f "$db_temp" ]; then

    # if exists, replace file
    sort -f "$db_temp" > "$DB_MAIN"
    rm "$db_temp"
  fi
}

# - - - - - - - - - - - - - - - - - -
# global variables

readonly MY_DIR="`readlink -f "$0" | sed 's#/[^/]*$##'`"
readonly BIN_LOOKUP="$MY_DIR/lookup.sh"
readonly GTLD_LIST="$MY_DIR/gtld.list"
readonly GTLD_DENY_LIST="$MY_DIR/gtld-deny.list"

# output file
readonly DB_FILENAME=whois-servers.csv
readonly DB_MAIN="$PWD/$DB_FILENAME"

# channel max
declare -i CH_MAX=5

# options

while getopts f opt
do
  case $opt in

    # if set, re-create the databse
    f) rm "$DB_MAIN" 2> /dev/null;;
  esac
done


# - - - - - - - - - - - - - - - - - -
# guard

# require gTLD list file
if [ ! -s "$GTLD_LIST" ]; then
  echo "require gTLD list file. ---> $GTLD_LIST"
  exit 1
fi

# - - - - - - - - - - - - - - - - - -
# main

# create file
create

