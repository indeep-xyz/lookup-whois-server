#!/bin/bash
#
# SUMMARY
#   lookup WHOIS server from TLD string
#
# USAGE:
#   $ lookup.sh [TLD]
#
#   if detected TLD then `echo "WHOIS-server's address"`
#   if could not detect TLD then `echo ""`
#



# - - - - - - - - - - - - - - - - - -
# functions

# = =
# lookup by *.whois-servers.net
#
# args
# $1 ... TLD string
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
# $1 ... TLD string
function lookup_iana() {

  # - check by telnet with port 43
  echo "$1" | curl -s telnet://whois.iana.org:43 | sed -n "s/^whois: \+//p"
}

# = =
# lookup by nic.*
# __buggy
#
# args
# $1 ... TLD string
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
# $1 ... TLD string
#
# echo
# domain name for passed TLD

WS=

WS=`lookup_iana $1`
[ -z "$WS" ] && WS=`lookup_wsnet $1`
# [ -z "$WS" ] && WS=`lookup_nic $1`

echo $WS
