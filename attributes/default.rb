#
# Cookbook Name:: chef-init-apache2-apps
# Attributes:: default
#
# Copyright 2014 Vubeology, LLC
#

default["mysql_database"]["data_bag_name"] = "mysql_database"

# Must be an absolute directory
#default["mysql_database"]["base_apps_dir"] = "/vagrant/apps"

# How to run the mysql client, including any authentication parameters
default["mysql_database"]["exec_mysql"] = "mysql"
