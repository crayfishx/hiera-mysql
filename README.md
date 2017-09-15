Introduction
============

This is hiera-mysql for Hiera 5 users (Puppet 4.9+) - if you are running older versions please see the [2.x branch for the hiera-mysql Hiera 3 backend](https://github.com/crayfishx/hiera-mysql/tree/2.x)

For more information on migrating to Hiera 5, [See the official documentation](https://docs.puppet.com/puppet/5.1/hiera_config_yaml_5.html)


Installation
============

`puppet module install crayfishx/hiera_mysql`


Dependencies
============

Hiera-mysql supports both native C extensions for use with standard ruby and the jRuby JDBC and will load whichever library is suitable for the ruby it has been installed on. This ensures that hiera-mysql operates under `puppet apply` which uses regular Ruby and also under `puppetserver` which implements jRuby.

If you are using Hiera-mysql under jRuby for Puppet Server you will need to install the jdbc gem:

`/opt/puppetlabs/bin/puppetserver gem install jdbc-mysql`

If you are using Hiera-mysql under standard ruby (eg: for puppet apply), you will need the mysql gem

`/opt/puppetlabs/puppet/bin/gem install mysql`


Versioning
==========

Hiera-mysql 2.0.0 is the legacy backend to Hiera 3.x and shipped as a rubygem.  Important fixes may still be contributed to the 2.x branch, however it's highly recommended that users switch to 3.x.  Hiera-mysql 3.0.0 is a complete refactor designed to work as a Hiera 5 backend, for users running Puppet 4.9 or higher.   Hiera-mysql 3.0.0 does not ship as a rubygem and should be used from the Puppet module.

Introduction
============

Hiera is a configuration data store with pluggable back ends, hiera-mysql is a back end that fetches configuration valus from a MySQL/MariaDB database.  It can be use instead of or along side other back ends.


Configuration
=============

There are two different ways to configure the mysql backend.  You can configure it as a `lookup_key` or `data_hash` backend.  The differences between these two types are [documented in the official Hiera docs](https://docs.puppet.com/puppet/5.1/hiera_custom_backends.html#three-kinds-of-backends).  `lookup_key` should be used to perform a MySQL query for each individual lookup request and return the value.   `data_hash` should be used to perform one MySQL query per catalog compilation that returns a key value map for all data values.  Examples of both methods can be found below.

### Example database

In the following examples, the following database structure is being used;

```
MariaDB [config]> DESC configdata;
+-------------+-----------+------+-----+---------+----------------+
| Field       | Type      | Null | Key | Default | Extra          |
+-------------+-----------+------+-----+---------+----------------+
| id          | int(11)   | NO   | PRI | NULL    | auto_increment |
| val         | char(255) | YES  |     | NULL    |                |
| var         | char(255) | YES  |     | NULL    |                |
| environment | char(255) | YES  |     | NULL    |                |
+-------------+-----------+------+-----+---------+----------------+
4 rows in set (0.00 sec)

MariaDB [config]> select * from configdata;
+----+-------------+---------------+-------------+
| id | val         | var           | environment |
+----+-------------+---------------+-------------+
|  1 | 192.168.0.1 | ntp::server   | production  |
|  2 | 10.1.1.2    | ntp::server   | development |
|  3 | Hello       | motd::message | production  |
+----+-------------+---------------+-------------+
```

### Hiera configuration

The hiera-mysql backend takes the following for the `options` hash of the Hiera configuration

* `host`: Hostname to connect to
* `username`: Username to use for authentication
* `password`: Password to use for authentication
* `database`: Name of the MySQL database
* `query`: The SQL query to run.  The special keyword `__KEY__` can be used to interpolate the lookup key into the query (only for lookup_key)
* `return`: For use with the lookup_key type.  When set to `first` will always return the first row even if the query returned multiple, when set to `array` will always return an array even if the query only returned one row.


### `lookup_key`

The `lookup_key` type defines a query that should be run for each lookup request and expects to return one value.  If the query returns multiple rows, then the first row will be returned.  `__KEY__` may be used in the query and will be interpolated as the lookup key.

Example:

```yaml
hierarchy:
  - name: "MySQL lookup"
    lookup_key: hiera_mysql
    options:
      host: localhost
      username: root
      password: foobar
      database: config
      query: "SELECT val FROM configdata WHERE var='__KEY__' AND environment='%{environment}'"
```

#### Arrays
The lookup_type method can return arrays.  By default, it will always return a string if one row is returned from the query, and will return an array when multiple rows are returned.  You can be more explicit by setting the `return` option in the `options` hash to:

`array`: Always return an array, even if the query only returned one row.
`first`: Always return the first row as a string, even if the query returned multiple rows.


### `data_hash`

The `data_hash` type defines a query that should be run just once for each Puppet run.  The query should be one that returns rows of two columns, the first column matching the key and the second with the value.  Further column will be ignored.

Example:

```yaml
hierarchy:
  - name: "MySQL lookup"
    data_hash: hiera_mysql
    options:
      host: localhost
      username: root
      password: foobar
      database: config
      query: "SELECT var,val FROM configdata WHERE environment='%{environment}'"
```


Contact
=======

* Maintainer: Craig Dunn
* Email: craig@craigdunn.org
* Twitter: @crayfishX
* IRC (Freenode): crayfishx
* Web: http://www.craigdunn.org


