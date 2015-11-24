#
# Cookbook Name:: APP_UBUNTU_Guacamole
# Recipe:: default
#
# Copyright 2015, Chris Beard
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apache2'
include_recipe 'APP_RHEL_guacamoleserver_0_1_0::java'
include_recipe 'APP_RHEL_guacamoleserver_0_1_0::apache_maven'
include_recipe 'APP_RHEL_guacamoleserver_0_1_0::tomcat'
include_recipe 'APP_RHEL_guacamoleserver_0_1_0::mod_auth_mellon'
include_recipe 'APP_RHEL_guacamoleserver_0_1_0::guacamole'