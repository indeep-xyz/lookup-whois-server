# lookup-whois-server

WHOIS server from gTLD

## lookup.sh

lookup WHOIS server from gTLD string.

### USAGE

#### command

`$ lookup.sh "gTLD"`

#### result

if succeeded to lookup gTLD then `echo "WHOIS-server's address"`

if failed to lookup gTLD then `echo ""`

## create-db.sh

create database of whois-servers by gTLD string. require *gtld.list* at the same location as this script. (include)

### USAGE

#### command

`$ create-db.sh`

#### result (lookuped)

if succeeded to lookup gTLD then write to *./whois-servers.csv*

<pre><code>gTLD,whois-server's address
gTLD,whois-server's address
gTLD,whois-server's address
...
</code></pre>

#### result (failed lookup)

if failed to lookup gTLD then write to \<STDOUT\>

you can using pipe( `| command` ) and write to file( `> filename` ), etc...

<pre><code>gTLD
gTLD
gTLD
...
</code></pre>

