#
# Cookbook Name:: APP_UBUNTU_Guacamole
# Recipe:: mod_auth_mellon
#
# Copyright 2015, Chris Beard
#
# All rights reserved - Do Not Redistribute
#

ruby_block 'set-env-java-home' do
  block do
    ENV['JAVA_HOME'] = "#{node['java']['home_path']}"
	ENV['JRE_HOME'] = "#{node['java']['jre_path']}"
	ENV['PATH'] = "#{ENV['PATH']}:#{node['java']['home_path']}:#{node['java']['jre_path']}:#{node['maven']['bin_directory']}"
  end
end

# Adding the following yum repos as some pachkages we need are not stored in the main repo
node['yum']['additional_repositories'].each do |repo|
	cookbook_file "/etc/yum.repos.d/#{repo}" do
		action :create
		not_if {File.exists?("/etc/yum.repos.d/#{repo}")}
		source "yum-epel repos/#{repo}"
	end
end

yum_package 'lasso' do
	action :install
	allow_downgrade true
	version '2.4.0-5.el6'
end

yum_package ['mod_auth_mellon', 'lasso-devel', 'libcurl-devel', 'openssl', 'openssl-devel', 'pkgconfig', 'autoconf',  'libtool', 'httpd-devel'] do
	action :install
end

#Enable SSL
include_recipe 'apache2::mod_ssl'

apache_site "default-ssl" do
	enable true
end

include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_headers'

directory '/etc/chef/wstunnel' do
	action :create
end

cookbook_file '/etc/chef/wstunnel/mod_proxy_wstunnel.c' do
	source 'mod_proxy_wstunnel.c'
	mode '0755'
	owner #{node['current_user']}
	group #{node['current_user']}
	notifies :run, 'execute[install_wstunnel]', :immediately
	notifies :run, 'template[configure_wstunnel]', :immediately
	notifies :run, 'execute[link_wstunnel_config]', :immediately
end

	execute 'install_wstunnel' do
		action :nothing
		command 'apxs -i -c mod_proxy_wstunnel.c'
		cwd '/etc/chef/wstunnel'
	end

	template 'configure_wstunnel' do
		action :nothing
		group #{node['current_user']}
		mode '0755'
		owner #{node['current_user']}
		path "#{node['apache']['dir']}/sites-available/proxy-wstunnel.conf"
		source 'proxy-wstunnel.conf.erb'
		variables({})
		not_if {File.exists?('/etc/httpd/sites-available/proxy-wstunnel.conf')}
	end

	execute "link_wstunnel_config" do
		command "ln -s #{node['apache']['dir']}/sites-available/proxy-wstunnel.conf #{node['apache']['dir']}/sites-enabled/proxy-wstunnel.conf"
		not_if {File.exists?("#{node['apache']['dir']}/sites-enabled/proxy-wstunnel.conf")}
		action :nothing
	end

#Copy Certificate and metadata from cookbook

####################
# At the moment we are installing the ssl certificates and metadata by hand, 
# until we can find a secure way of passing the primary key with the cookbook
####################

base_url = node['mod_auth_mellon']['base_url'].downcase
cert_name = node['mod_auth_mellon']['cert_name'].downcase

directory "#{node['apache']['dir']}/ssl" do
	action :create
end

unless File.exists?("#{node['apache']['dir']}/ssl/#{cert_name}.crt" ) 
	execute 'copy_certificate' do
		command "cp /etc/chef/#{cert_name}.crt /#{node['apache']['dir']}/ssl/#{cert_name}.crt"
	end
end

unless File.exists?("#{node['apache']['dir']}/ssl/#{cert_name}.key" ) 
	execute 'copy_key' do
		command "cp /etc/chef/#{cert_name}.key /#{node['apache']['dir']}/ssl/#{cert_name}.key"
	end
end

directory "#{node['apache']['dir']}/mellon" do
	action :create
end

unless File.exists?("#{node['apache']['dir']}/mellon/#{cert_name}.xml" ) 
	execute 'copy_sp_metadata' do
		command "cp /etc/chef/#{cert_name}.xml /#{node['apache']['dir']}/mellon/#{cert_name}.xml"
	end
end

unless File.exists?("#{node['apache']['dir']}/mellon/idp-metadata.xml" ) 
	execute 'copy_sp_metadata' do
		command "cp /etc/chef/idp-metadata.xml /#{node['apache']['dir']}/mellon/idp-metadata.xml"
	end
end

#Create default apache ssl conf
template "#{node['apache']['dir']}/sites-available/default-ssl.conf" do
	group #{node['current_user']}
	mode '0755'
	owner #{node['current_user']}
	source 'default-ssl.conf.erb'
	variables({})
	notifies :run, 'execute[link_default_ssl_conf]'
end

	execute 'link_default_ssl_conf' do
		command "ln -s #{node['apache']['dir']}/sites-available/default-ssl.conf #{node['apache']['dir']}/sites-enabled/default-ssl.conf"
		not_if {File.exists?("#{node['apache']['dir']}/sites-enabled/default-ssl.conf")}
	end

#Update the mellon.conf file
template "#{node['apache']['dir']}/sites-available/mellon.conf" do
	mode '0744'
	source 'mellon.conf.erb'
	variables({})
	notifies :run, 'execute[link_melon_conf]', :immediately
end

	execute 'link_mellon_conf' do
		command "ln -s #{node['apache']['dir']}/sites-available/mellon.conf #{node['apache']['dir']}/sites-enabled/mellon.conf"
		not_if {File.exists?("#{node['apache']['dir']}/sites-enabled/mellon.conf")}
	end

service 'httpd' do
	action :restart
end

#######
# Clean up
#######

directory '/etc/chef/wstunnel' do
	action :delete
end