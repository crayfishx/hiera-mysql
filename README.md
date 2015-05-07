
Installation
============

On native system Ruby (not jRuby) for Puppet < 3.7

`gem install hiera-mysql`


On Puppet 4.0 for standard Ruby

`/opt/puppetlabs/puppet/bin/gem install hiera-mysql`

On Puppet 4.0 for jRuby (puppetserver)

`/opt/puppetlabs/bin/puppetserver gem install hiera-mysql`


*IMPORTANT NOTE* hiera-mysql also ships as a Puppet module, which can be synced with the puppet master using pluginsync, if you are using this model, please read [SERVER-571](https://tickets.puppetlabs.com/browse/SERVER-571) - At the time of 2.0.0 release no decision has been made on long term support for shipping hiera backends as modules.

`puppet module install crayfishx/hiera-mysql`


Dependancies
============

Hiera-mysql 1.0.0 and lower specifies a gem dependancy for the native mysql extensions (mysql).  2.0.0 supports both native C extensions and the jRuby JDBC and will load whichever library is suitable for the ruby it has been installed on.  When installing the gem within puppetserver (jRuby) for Puppet 4.0 the native C extensions cannot be compiled therefore we have dropped this as a hard gem dependancy and added it as user information (spec.requirements)

If you are installing Hiera-mysql under jRuby for Puppet 4.0 you will need to manually install the jdbc gem

`/opt/puppetlabs/bin/puppetserver gem install jdbc-mysql`

If you are installing Hiera-mysql under standard ruby, you will need the mysql gem

`/opt/puppetlabs/puppet/bin/gem install mysql`


Versioning
==========

Hiera-mysql 0.2.0 was re-released as 1.0.0 - there are no significant changes between these two.  Looking back, 0.2.0 should probably have been a 1.0 release and the last major release was a very big change.  Rightly or wrongly I personally feel that 0.x to 1.x signifies a state of readyness rather than change, whereas 1.x to 2.x makes it clear there are likely to be breaking changes.  So with the introduction of the jRuby code I decided to re-release 0.2.0 as 1.0.0 and release the jRuby changes as 2.0.0.


Introduction
============

Hiera is a configuration data store with pluggable back ends, hiera-mysql is a back end that fetches configuration valus from a MySQL database.  It can be use instead of or along side other back ends.


Configuration
=============

hiera-mysql configuration is fairly simple.  The query specified in mysqlquery is parsed by Hiera to interpret any %{var} values specifed in the scope.  It also has the ability to interpret %{key} (the name of the value you're searching for) directly into the SQL string.

Here is a sample hiera.yaml file that will work with mysql

<pre>
---
:backends: 
    - mysql

:mysql:
    :host: localhost
    :user: root
    :pass: examplepassword
    :database: config

    :query: SELECT val FROM configdata WHERE var='%{key}' AND environment='%{env}'


:logger: console


</pre>

:query: can be either a string or an array - if it's an array then each query is executed in order (similar to the :hierarchy: configuration parameter for the YAML backend.  So the above could be configured as

<pre>
    :query:
      - SELECT val FROM configdata WHERE var='%{key}' AND environment='%{env}'
      - SELECT val FROM configdata WHERE var='%{key}' AND location='%{location}'
      - SELECT val FROM configdata WHERE var='%{key}' AND environment='common'
</pre>

Results and data types
======================



When looking up a single column (eg: SELECT foo FROM bar):

* `hiera()` will run iterate through each query and give back the first row returned.

* `hiera_array()` will iterate through each query and return an array of the  _every_ row returned from all the queries

When looking up multiple columns (eg: SELECT foo,bar FROM baz):

* `hiera()` will iterate through each query and return a _hash_ of the first row as `{column => value}` eg:

<pre>
DEBUG: Wed Oct 31 03:35:41 +0000 2012: Executing SQL Query: SELECT val,id FROM configuration WHERE var='color' AND env='common' OR env='qa'
DEBUG: Wed Oct 31 03:35:41 +0000 2012: Mysql Query returned 4 rows
{"id"=>"5", "val"=>"pink"}
</pre>

* `hiera_array()` will iterate through each query and return _an array of hashes_ for every row returned from all queries, eg:

<pre>
DEBUG: Wed Oct 31 03:35:49 +0000 2012: Executing SQL Query: SELECT val,id FROM configuration WHERE var='color' AND env='common' OR env='qa'
DEBUG: Wed Oct 31 03:35:49 +0000 2012: Mysql Query returned 4 rows
[{"val"=>"pink", "id"=>"5"}, {"val"=>"red", "id"=>"6"}, {"val"=>"rose", "id"=>"7"}, {"val"=>"plain white", "id"=>"10"}]
</pre>

Release Notes
=============

_0.2.0_:
* Added array support
* Added multi-column hashes
* First Puppet Forge release


Todo
====

- Better MySQL error/exception handling



Contact
=======

* Author: Craig Dunn
* Email: craig@craigdunn.org
* Twitter: @crayfishX
* IRC (Freenode): crayfishx
* Web: http://www.craigdunn.org


