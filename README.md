IMPORTANT
=========

If you are planning to use hiera-mysql with Puppet, please be aware of this issue with hiera  0.3.0 and lower

https://github.com/crayfishx/hiera-mysql/issues/2

hiera-mysql will work with the upcoming 0.3.1 release of hiera, but until then you will have to apply the commit in:

http://projects.puppetlabs.com/issues/13641

A new hiera-mysql gem will be release to co-incide with the fixed hiera one when it comes out.

 

Introduction
============

Hiera is a configuration data store with pluggable back ends, hiera-mysql is a back end that fetches configuration valus from a MySQL database.  It can be use instead of or along side other back ends.


Configuration
=============

hiera-mysql configuration is fairly simple.  The query specified in mysqlquery is parsed by Hiera to interpret any %{var} values specifed in the scope.  It also has the ability to interpret %{key} (the name of the value you're searching for) directly into the SQL string.

Here is a sample hiera.yaml file that will work with mysql

<pre>
---
:backends: - mysql

:mysql:
    :host: localhost
    :user: root
    :pass: examplepassword
    :database: config

    :query: SELECT val FROM configdata WHERE var='%{key}' AND environment='%{env}'


:logger: console


</pre>

Todo
====

- Support for hashes to facilitate selecting more than one column
- Support for multiple SQL queries (like :hierarchy:)
- Better MySQL error/exception handling



Contact
=======

* Author: Craig Dunn
* Email: craig@craigdunn.org
* Twitter: @crayfishX
* IRC (Freenode): crayfishx
* Web: http://www.craigdunn.org


