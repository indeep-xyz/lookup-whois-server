#!/bin/bash
#
# SUMMARY
#   lookup WHOIS server from gTLD string
#
# USAGE:
#   $ lookup.sh [gTLD]
#
#   if detected gTLD then `echo [WHOIS-server's address]`
#   if could not detect gTLD then `echo ""`
#



# - - - - - - - - - - - - - - - - - -
# functions

# = =
# lookup by *.whois-servers.net
#
# args
# $1 ... gTLD string
function lookup_wsnet() {

  local server=
  local text="`\
      host -t a "${1}.whois-servers.net" \
        | sed -n "s/.* is an alias for \([^ ]*\)\.$/\1/p"`"

  for line in ${text[@]}
  do
    server="$line"
  done

  echo $server
}

## = =
# lookup by whois.iana.org
#
# args
# $1 ... gTLD string
function lookup_iana() {

  # - check by telnet with port 43
  echo "$1" | curl -s telnet://whois.iana.org:43 | sed -n "s/^whois: \+//p"
}

# = =
# lookup by nic.*
# __buggy
#
# args
# $1 ... gTLD string
function lookup_nic() {

  # - check by telnet with port 43
  echo "nic.$1" | curl -s "telnet://whois.nic.${1}:43" | sed -n "s/^WHOIS Server: *//p"
}

# - - - - - - - - - - - - - - - - - -
# guard

if [ $# -lt 1 ]; then

  echo 'REQUIRE $1'
  exit 1
fi

# - - - - - - - - - - - - - - - - - -
# main

# args
# $1 ... gTLD string
#
# echo
# domain name for passed gTLD

WS=

WS=`lookup_iana $1`
[ -z "$WS" ] && WS=`lookup_wsnet $1`
# [ -z "$WS" ] && WS=`lookup_nic $1`

echo $WS
