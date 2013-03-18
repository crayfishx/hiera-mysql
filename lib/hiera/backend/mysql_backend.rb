# Class Mysql_backend
# Description: MySQL back end to Hiera.
# Author: Craig Dunn <craig@craigdunn.org>
#
class Hiera
    module Backend
        class Mysql_backend
            def initialize
                begin
                  require 'mysql'
                rescue LoadError
                  require 'rubygems'
                  require 'mysql'
                end

                Hiera.debug("mysql_backend initialized")
            end
            def lookup(key, scope, order_override, resolution_type)

                Hiera.debug("mysql_backend invoked lookup")
                Hiera.debug("resolution type is #{resolution_type}")

                answer = nil

                # Parse the mysql query from the config, we also pass in key
                # to extra_data so this can be interpreted into the query 
                # string
                #
                queries = [ Config[:mysql][:query] ].flatten
                queries.map! { |q| Backend.parse_string(q, scope, {"key" => key}) }

                queries.each do |mysql_query|

                  results = query(mysql_query)

                  unless results.empty?
                    case resolution_type
                      when :array
                        answer ||= []
                        results.each do |ritem|
                          answer << Backend.parse_answer(ritem, scope)
                        end
                      else
                       answer = Backend.parse_answer(results[0], scope)
                       break
                    end
                  end

                end
              answer
            end

            def query (sql)
                Hiera.debug("Executing SQL Query: #{sql}")

                data=[]
                mysql_host=Config[:mysql][:host]
                mysql_user=Config[:mysql][:user]
                mysql_pass=Config[:mysql][:pass]
                mysql_database=Config[:mysql][:database]
                mysql_charset=Config[:mysql][:charset]

                dbh = Mysql.new(mysql_host, mysql_user, mysql_pass, mysql_database)
                dbh.reconnect = true

                if not mysql_charset.nil?
                  dbh.query("SET names #{mysql_charset}")
                end

                res = dbh.query(sql)
                Hiera.debug("Mysql Query returned #{res.num_rows} rows")


                # Currently we'll just return the first element of each row, a future
                # enhancement would be to make this easily support hashes so you can do
                # select foo,bar from table
                #
                if res.num_fields < 2
                  res.each do |row|
                    Hiera.debug("Mysql value : #{row[0]}")
                    data << row[0]
                  end

                else
                  res.each_hash do |row|
                    data << row
                  end
                end

                return data
            end
        end
    end
end


