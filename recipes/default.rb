#
# Cookbook Name:: chef-init-mysql-database
# Recipe:: default
#
# Copyright 2014, Vubeology, LLC
#
# Initialize database permissions
#

have_config = false

begin
    mysql_users         = data_bag_item(node["mysql_database"]["data_bag_name"], "users")
    mysql_databases     = data_bag_item(node["mysql_database"]["data_bag_name"], "databases")
    have_config         = true
rescue
    Chef::Log.warn "WARNING: Unable to load #{node["mysql_database"]["data_bag_name"]} data bag."
end

if have_config == true

    # 1) Set up permissions on databases & users

    template "/tmp/mysql_permissions.sql" do
        source "mysql_permissions.sql.erb"
        owner  "root"
        mode   0700
        variables({
                          :mysql_users         => mysql_users,
                          :mysql_databases     => mysql_databases
                  })
    end

    execute "init-mysql-database-permissions" do
        command "#{node["mysql_database"]["exec_mysql"]} < /tmp/mysql_permissions.sql"
        only_if { File.exist?("/tmp/mysql_permissions.sql") }
    end

    # 2) Initialize databases

    ruby_block "init-databases" do
        block do
            mysql_databases["databases"].each do |db_name, db|
                Vube::InitMysqlDatabase.initDB(node, db_name, db)
            end
        end
    end

end
