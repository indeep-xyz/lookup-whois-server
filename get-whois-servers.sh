#!/bin/bash
#
# USAGE:
#   $ get-whois-servers.sh
#
#   create (or update) to ./whois-servers.list
#
#   format is CSV
#   <gTLD>,<whois-server's address>

# - - - - - - - - - - - - - - - - - -
# functions

function lookup(){

  local -i COUNT_MAX=`wc -l $GTLD_LIST | sed 's/^\([0-9]\+\).*/\1/'`
  local -i COUNT=0

  # remove old temporary
  rm -f "$O_TEMP"

  # main
  cat $GTLD_LIST | while read GTLD;
  do

    let COUNT++
    printf "%d/%d %s" $COUNT $COUNT_MAX $GTLD

    # pattern 1
    # - check by telnet with port 43
    TEMP="$(echo $GTLD | curl -s telnet://whois.iana.org:43 | sed -n "s/^whois: \+//p")"

    # pattern 2
    # - check by *.whois-servers.net
    [ -z "$TEMP" ] \
      && TEMP="$(\
        host "${GTLD}.whois-servers.net" \
        | sed -n "s/^${GTLD}\.whois-servers\.net is an alias for \(.*\)\.$/\1/p" \
        )"

    # if not empty text, add to temporary file
    [ -n "$TEMP" ] \
      && echo "$GTLD,$TEMP" >> "$O_TEMP"

    # clear strings
    printf "[200D"
    printf "[K"
  done
}

# - - - - - - - - - - - - - - - - - -
# global variables

readonly MY_DIR="`readlink -f "$0" | sed 's#/[^/]*$##'`"
readonly GTLD_LIST=gtld.list

# output file
readonly O_FILENAME=whois-servers.list
readonly O_FILE="$MY_DIR/$O_FILENAME"
readonly O_TEMP="$MY_DIR/${O_FILENAME}.~temp"
readonly O_LOCK="$MY_DIR/${O_FILENAME}.~lock"

# - - - - - - - - - - - - - - - - - -
# guard

# require gTLD list file
if [ ! -s "$GTLD_LIST" ]; then
  echo "require gTLD list file. ---> $GTLD_LIST"
  exit 1
fi

# create and check lock file
if ! ln "$O_FILE" "$O_LOCK"; then
  echo "lock file is exists. ---> $O_LOCK"
  echo "if you want run this script, remove it."
  exit 1
fi

# - - - - - - - - - - - - - - - - - -
# main

# run main (create temp)
lookup

# apply list
mv "$O_TEMP" "$O_FILE"

# remove lock file
rm -f "$O_LOCK"
