#!/bin/bash
#
# SUMMARY
#   create database of whois-servers by TLD string
#   require 'tld.list' at the same location as this script
#
# USAGE:
#   $ create-db.sh
#
#   if succeeded to lookup TLD then write to ./whois-servers.csv
#   - format
#   [TLD],[whois-server's address]
#   [TLD],[whois-server's address]
#   [TLD],[whois-server's address]
#   ...
#
#   if failed to lookup TLD then write to <STDOUT>
#   you can using pipe and write to file, etc...
#   - format
#   [TLD]
#   [TLD]
#   [TLD]
#   ...
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
# $1 ... TLD string
# $2 ... database path for push
function push_routine() {

  local tld="$1"
  local db="$2"
  local ws="`$BIN_LOOKUP $tld`"

  # check return value
  if [ -n "$ws" ]; then

    # if not empty
    # - push to database file
    push "$db" "$tld,$ws"
  else

    # if empty (lookup failure)
    # - echo
    echo $tld
  fi
}

# = =
# get TLD list
# if exists in database, excluding TLD
#
# depend variables
# $TLD_LIST      ... list for TLD
# $TLD_IGNORE_LIST ... deny list for TLD
# $DB_MAIN        ... existing database made by this script
#
# echo
# line separated TLD string
function get_list() {

  local gl="`cat "$TLD_LIST"`"
  local db=

  # check database file
  if [ ! -f "$DB_MAIN" ]; then

    # if not exists, echo full
    echo -e "$gl"
  else

    # if exists
    # - echo non-existence TLD string

    db="`cat "$DB_MAIN" "$TLD_IGNORE_LIST" | sed 's/,.*$//'`"

    echo -e "$gl" | while read tld;
    do
      if ! echo -e "$db" | grep -q "^$tld"; then
        echo $tld
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
# line separated TLD string
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
  echo -e "$gl" | while read tld;
  do

    push_routine $tld "$db_temp" &
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
readonly TLD_LIST="$MY_DIR/tld.list"
readonly TLD_IGNORE_LIST="$MY_DIR/tld-ignore.list"

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

# require TLD list file
if [ ! -s "$TLD_LIST" ]; then
  echo "require TLD list file. ---> $TLD_LIST"
  exit 1
fi

# - - - - - - - - - - - - - - - - - -
# main

# create file
create

