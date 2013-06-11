IMPORTANT
=========

Requires hiera-puppet 1.0.0 or above

Installation
============

`gem install hiera-mysql`

or

`puppet module install crayfishx/hiera_mysql`


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
    :keyregex: !ruby/regexp '/mymodule:/'


:logger: console


</pre>

:query: can be either a string or an array - if it's an array then each query is executed in order (similar to the :hierarchy: configuration parameter for the YAML backend.  So the above could be configured as

<pre>
    :query:
      - SELECT val FROM configdata WHERE var='%{key}' AND environment='%{env}'
      - SELECT val FROM configdata WHERE var='%{key}' AND location='%{location}'
      - SELECT val FROM configdata WHERE var='%{key}' AND environment='common'
</pre>

:keyregex: is an optional parameter that can be used to specify a regular expression that the key must match in order for the mysql lookup to be invoked.  In the sample hiera.yaml, the mysql backend is only used to lookup keys from a specific module.
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


