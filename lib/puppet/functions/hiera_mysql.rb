# Copyright 2017 Craig Dunn <craig@craigdunn.org>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# Class Mysql_backend
# Description: MySQL back end to Hiera 5.
# Author: Craig Dunn <craig@craigdunn.org>
#
#
Puppet::Functions.create_function(:hiera_mysql) do

  if defined?(JRUBY_VERSION)
    begin
      require 'java'
      require 'jdbc/mysql'
    rescue LoadError
      raise Puppet::DataBinding::LookupError, "Error loading jdbc-mysql gem library."
    end
  else
    begin
      require 'mysql'
    rescue LoadError
      raise Puppet::DataBinding::LookupError, "Error loading mysql gem library."
    end
  end

  dispatch :mysql_lookup_key do
    param 'Variant[String, Numeric]', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  dispatch :mysql_data_hash do
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def is_number? string
    true if Float(string) rescue false
  end

  def mysql_data_hash(options, context)
    context.explain { "data_hash lookup with query: #{options['query']}" }
    results = query(options['query'], context, options)
    if results.empty?
      context.not_found
    else
      return Hash[results.collect { |i| [ i[i.keys[0]], i[i.keys[1]] ] } ]
    end
  end





  def mysql_lookup_key(key, options, context)
    mysql_query = options['query'].gsub('__KEY__', key)

    if context.cache_has_key(mysql_query)
      context.explain { "Returning cached value for #{mysql_query}" }
      return context.cached_value(mysql_query)
    end

    context.explain { "MySQL Lookup with query: #{mysql_query}" }
    results = query(mysql_query, context, options)

    if results.empty?
      context.not_found
    else
      return results if options['return'] == 'array'
      return results[0] if options['return'] == 'first'
      return results.length > 1 ? results : results[0]
    end
  end

  def query(sql, context, options)

    data=[]
    mysql_host=options['host']
    mysql_user=options['username']
    mysql_pass=options['password']
    mysql_database=options['database']

    
    if defined?(JRUBY_VERSION)
      #
      # JDBC connection handling, this will be run under jRuby
      #
      if context.cache_has_key('_conn')
        conn = context.cached_value('_conn')
      else
        Jdbc::MySQL.load_driver
        url = "jdbc:mysql://#{mysql_host}:3306/#{mysql_database}"
        props = java.util.Properties.new
        props.set_property :user, mysql_user
        props.set_property :password, mysql_pass

        conn = com.mysql.jdbc.Driver.new.connect(url,props)
        context.cache('_conn', conn)
      end

      stmt = conn.create_statement

      res = stmt.execute_query(sql)
      md = res.getMetaData
      numcols = md.getColumnCount

      while ( res.next ) do
        if numcols < 2
          data << res.getString(1).to_f if is_number?(res.getString(1))
          data << res.getString(1) if !is_number?(res.getString(1))
        else
          row = {}
          (1..numcols).each do |c|
            row[md.getColumnName(c)] = res.getString(c).to_f if is_number?(res.getString(c))
            row[md.getColumnName(c)] = res.getString(c) if !is_number?(res.getString(c))
          end
          data << row  
        end
      end
    else
    #
    # Native mysql connection, for calls outside of jRuby
    #
      if context.cache_has_key('_dbh')
        dbh = context.cached_value('_dbh')
      else
        dbh = Mysql.new(mysql_host, mysql_user, mysql_pass, mysql_database)
        dbh.reconnect = true
        context.cache('_dbh', dbh)
      end

      res = dbh.query(sql)

      if res.num_fields < 2
        res.each do |row|
          data << row[0]
        end
      else
        res.each_hash do |row|
          data << row
        end
      end
    end
    return data
  end
end
