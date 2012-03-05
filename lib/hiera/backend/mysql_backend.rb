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
                mysql_host = Config[:mysql][:host]
            end
            def lookup(key, scope, order_override, resolution_type)
                Hiera.debug("loaded mysql backend")


                # Parse the mysql query from the config, we also pass in key
                # to extra_data so this can be interpreted into the query 
                # string
                #
                mysql_query = Backend.parse_string(Config[:mysql][:query], scope, { "key" => key })


                answer = Backend.empty_answer(resolution_type)
                Hiera.debug("resolution type is #{resolution_type}")

                results = query(mysql_query)
                unless results.empty?
                    case resolution_type
                        when :array
                            results.each do |ritem|
                                answer << Backend.parse_answer(ritem, scope)
                            end
                        else
                            answer = Backend.parse_answer(results[0], scope)
                        end
                end

                    return answer

            end
                
         

            def query (sql) 
                Hiera.debug("Executing SQL Query: #{sql}")

                data=[]
                mysql_host=Config[:mysql][:host]
                mysql_user=Config[:mysql][:user]
                mysql_pass=Config[:mysql][:pass]
                mysql_database=Config[:mysql][:database]

                dbh = Mysql.new(mysql_host, mysql_user, mysql_pass, mysql_database)
                dhb.reconnect = true
                
                res = dbh.query(sql)
                Hiera.debug("Mysql Query returned #{res.num_rows} rows")


                # Currently we'll just return the first element of each row, a future
                # enhancement would be to make this easily support arrays so you can do
                # select foo,bar from table
                res.each do |row|
                    Hiera.debug("Mysql value : #{row[0]}")
                    data << row[0]
                end

                return data

            end
        end
    end
end


