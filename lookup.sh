#!/bin/bash



# - - - - - - - - - - - - - - - - - -
# functions

# = =
# lookup by *.whois-servers.net
#
# args
# $1 ... gTLD string
function lookup_wsnet() {

  host -t a "${1}.whois-servers.net" \
    | sed -n "1s/.* is an alias for \(.*\)\.$/\1/p"
}

# = =
# lookup by *.whois-servers.net
#
# args
# $1 ... gTLD string
function lookup_iana() {

  # - check by telnet with port 43
  echo $1 | curl -s telnet://whois.iana.org:43 | sed -n "s/^whois: \+//p"
}

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

echo $WS
