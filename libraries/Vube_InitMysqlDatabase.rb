module Vube
    module InitMysqlDatabase

        def self.initDB(node, db_name, db)

            # Query to see if there are any tables in this database
            Chef::Log.info "Connect MySQL: #{node["mysql_database"]["exec_mysql"]}"
            show_tables_output = `#{node["mysql_database"]["exec_mysql"]} -e 'show tables in #{db_name}'`

            # If there is at least 1 table already, we assume the DB is initialized
            db_exists = show_tables_output && !show_tables_output.to_s.empty?
            Chef::Log.info "Initialized #{db_name} DB Exists: #{db_exists}"

            if db_exists == false

                # There are no tables in this DB, so preload the DB with init.sql routines
                preload = preloadDB(node, db_name, db)

                if preload == false
                    Chef::Log.info "DB is not initialized, skipping #{db_name} DB"
                end
            end
        end

        def self.preloadDB(node, db_name, db)

            loaded = false

            # IFF there is an init.sql defined, (it may be a filename or a glob)
            # then try to execute the init.sql for this database

            if db["init.sql"] && !db["init.sql"].to_s.empty?

                # init.sql can be "/path/to/file.sql" or "/path/to/all/*.sql"

                Dir.glob(db["init.sql"]).each do |f|

                    Chef::Log.info "Initializing #{db_name} DB: #{f}"
                    system "#{node["mysql_database"]["exec_mysql"]} '#{db_name}' < '#{f}'"

                    # If the system command exited non-zero, there was an error
                    if $? != 0
                        raise "Error initializing #{db_name} DB: #{f} (mysql exited with status #{$?})"
                    end
                    loaded = true
                end
            else
                Chef::Log::warn "WARNING: There is no init.sql defined in the mysql_database config for DB #{db_name}"
            end

            loaded
        end

    end
end

Chef::Recipe.send(:include, Vube::InitMysqlDatabase)
