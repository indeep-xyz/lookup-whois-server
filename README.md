# lookup-whois-server

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

## OTHER FILES

### gtld.list

gTLD list for lookup by *create-db.sh* (REQUIRE)

<pre><code>gTLD
gTLD
gTLD
...
</code></pre>

### gtld-ignore.list

gTLD list for not lookup by *create-db.sh*

<pre><code>gTLD
gTLD
gTLD
...
</code></pre>

### unknown.list

created by *create-db.sh* from `> unknown.list`

records are gTLD that failed lookup

<pre><code>gTLD
gTLD
gTLD
...
</code></pre>

### whois-servers.csv

created by *create-db.sh*

records are gTLD and WHOIS server's address that succeed lookup

<pre><code>gTLD,whois-server's address
gTLD,whois-server's address
gTLD,whois-server's address
...
</code></pre>

## AUTHOR

[indeep-xyz](http://indeep.xyz/)
