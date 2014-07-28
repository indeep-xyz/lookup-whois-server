# lookup-whois-server

## lookup.sh

lookup WHOIS server from TLD string.

### USAGE

#### command

`$ lookup.sh "TLD"`

#### result

if succeeded to lookup TLD then `echo "WHOIS-server's address"`

if failed to lookup TLD then `echo ""`

## create-db.sh

create database of whois-servers by TLD string. require *tld.list* at the same location as this script. (include)

### USAGE

#### command

`$ create-db.sh`

#### result (lookuped)

if succeeded to lookup TLD then write to *./whois-servers.csv*

<pre><code>TLD,whois-server's address
TLD,whois-server's address
TLD,whois-server's address
...
</code></pre>

#### result (failed lookup)

if failed to lookup TLD then write to \<STDOUT\>

you can using pipe( `| command` ) and write to file( `> filename` ), etc...

<pre><code>TLD
TLD
TLD
...
</code></pre>

## OTHER FILES

### tld.list

TLD list for lookup by *create-db.sh* (REQUIRE)

<pre><code>TLD
TLD
TLD
...
</code></pre>

### tld-ignore.list

TLD list for not lookup by *create-db.sh*

<pre><code>TLD
TLD
TLD
...
</code></pre>

### unknown.list

created by *create-db.sh* from `> unknown.list`

records are TLD that failed lookup

<pre><code>TLD
TLD
TLD
...
</code></pre>

### whois-servers.csv

created by *create-db.sh*

records are TLD and WHOIS server's address that succeed lookup

<pre><code>TLD,whois-server's address
TLD,whois-server's address
TLD,whois-server's address
...
</code></pre>

## AUTHOR

[indeep-xyz](http://indeep.xyz/)
