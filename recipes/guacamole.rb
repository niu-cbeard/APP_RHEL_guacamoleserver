#
# Cookbook Name:: APP_UBUNTU_Guacamole
# Recipe:: guacamole
#
# Copyright 2015, Chris Beard
#
# All rights reserved - Do Not Redistribute
#

# This file is managed by Chef - Cookbook Name :: APP_RHEL_guacamoleserver_0_1_0
# Any manual changes made to this file will be deleted with the next chef run.

ruby_block 'set-env-java-home' do
  block do
    ENV['JAVA_HOME'] = "#{node['java']['home_path']}"
	ENV['JRE_HOME'] = "#{node['java']['jre_path']}"
	ENV['PATH'] = "#{ENV['PATH']}:#{node['java']['home_path']}:#{node['java']['jre_path']}:#{node['maven']['bin_directory']}"
  end
end

# Adding the following yum repos as some packages we need are not stored in the main repo
node['yum']['additional_repositories'].each do |repo|
	cookbook_file "/etc/yum.repos.d/#{repo}" do
		action :create
		not_if {File.exists?("/etc/yum.repos.d/#{repo}")}
		source "yum-epel repos/#{repo}"
	end
end

yum_package ['cairo-devel', 'libpng-devel', 'libjpeg-turbo-devel', 'uuid-devel', 'pango-devel' ,'freerdp-devel',
	'libssh2-devel', 'libtelnet-devel', 'libvncserver-devel',
	'pulseaudio-libs-devel', 'openssl-devel', 'libvorbis-devel', 'libtool'] do
	action :install
end

yum_package ['guacd', 'libguac-client-ssh', 'libguac-client-vnc', 'libguac-client-rdp'] do
	action :install
end

#This is the guacamole server distribution
cookbook_file "/etc/chef/#{node['guacamole']['distribution_file_name']}" do
	action :create
	source #{node['guacamole']['distribution_file_name']}	
	notifies :run, 'execute[extract_guacamole_server]', :immediately
	notifies :run, 'execute[autoreconf_guacamole_server]', :immediately
	notifies :run, 'execute[configure_guacamole_server]', :immediately
	notifies :run, 'execute[make_guacamole_server]', :immediately
	notifies :run, 'execute[install_guacamole_server]', :immediately
	notifies :run, 'execute[ldconfig_guacamole_server]', :immediately
	notifies :run, 'execute[chkconfig_guacd]', :immediately
end
 
	execute 'extract_guacamole_server' do
		action :nothing
		command "tar -xvf #{node['guacamole']['distribution_file_name']}"
		cwd "/etc/chef"
	end

	execute 'autoreconf_guacamole_server' do
		action :nothing
		command "autoreconf -fi"
		cwd "/etc/chef/#{node['guacamole']['distribution_path']}"
	end

	execute 'configure_guacamole_server' do
		action :nothing
		command './configure --with-init-dir=/etc/init.d'
		cwd "/etc/chef/#{node['guacamole']['distribution_path']}"
	end

	execute 'make_guacamole_server' do
		action :nothing
		cwd "/etc/chef/#{node['guacamole']['distribution_path']}"
		command 'make'
	end

	execute 'install_guacamole_server' do
		action :nothing
		cwd "/etc/chef/#{node['guacamole']['distribution_path']}"
		command 'make install'
	end

	execute 'ldconfig_guacamole_server' do
		action :nothing
		command 'ldconfig'
		cwd "/etc/chef/#{node['guacamole']['distribution_path']}"
	end

	#execute "update-rc.d guacd defaults" do
	#	command "update-rc.d guacd defaults"
	#	cwd "/etc/chef/#{node['guacamole']['distribution_path']}"
	#end

	execute 'chkconfig_guacd' do
		action :nothing
		command 'chkconfig guacd on'
	end
	
cookbook_file "/var/lib/tomcat/webapps/guacamole.war" do
	action :create
	source "guacamole.war"
	notifies :run, 'execute[extract_guacamole_client]' :immediately
end

	execute 'extract_guacamole_client' do
		action :nothing
		command "jar xvf ../guacamole.war" 
		cwd "/var/lib/tomcat/webapps/guacamole"
	end

node['guacamole']['freerdp_files'].each do |file|
	execute "ln -s /usr/local/lib/freerdp/#{file} /usr/lib64/freerdp/#{file}" do
		command  "ln -s /usr/local/lib/freerdp/#{file} /usr/lib64/freerdp/#{file}"
		not_if {File.exists?("/usr/lib64/freerdp/#{file}")}
	end
end

#sudo mkdir /etc/guacamole
directory '/etc/guacamole' do
	action :create
end

directory "/usr/share/tomcat/.guacamole" do
	action :create
end

base_url = node['mod_auth_mellon']['base_url'].downcase

#Create a guacamole configuration file as per below
template '/etc/guacamole/guacamole.properties' do
	action :create
	group #{node['current_user']}
	mode '0755'
	owner #{node['current_user']}
	source 'guacamole.properties.erb'
	variables({ :hostname => base_url})
	notifies :run, 'execute[link_guacamole_properties]', :immediately
end

	execute "link_guacamole_properties" do
		action :nothing
		command "ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat/.guacamole/"	
		not_if {File.exists?("/usr/share/tomcat/.guacamole/guacamole.properties")}	
	end

cookbook_file "/etc/guacamole/applications.xml" do
	action :create
	source "applications.xml"
end

#Replace the <Location /guacamole/> from the apache2.conf
template "#{node['apache']['dir']}/sites-available/guacamole.conf" do
	action :create
	group #{node['current_user']}
	mode '0755'
	owner #{node['current_user']}
	source 'guacamole.conf.erb'
	variables({
		:proxy_pass => 	"http://#{base_url}:8080/guacamole max=20 flushpackets=on",
		:proxy_pass_reverse => "http://#{base_url}:8080/guacamole"
	})
	notifies :run, 'execute[link_guacamole_conf]', :immediately
end

	execute "link_guacamole_conf" do
		action :nothing
		command  "ln -s #{node['apache']['dir']}/sites-available/guacamole.conf #{node['apache']['dir']}/sites-enabled/guacamole.conf"
		not_if {File.exists?("#{node['apache']['dir']}/sites-enabled/guacamole.conf")}
	end

cookbook_file "/etc/chef/samlAuth.tar" do
	action :create
	source "samlAuth.tar"
	notifies :run, 'execute[extract_saml_auth]', :immediately
	notifies :run, 'execute[maven_saml_auth]', :immediately
	notifies :run, 'execute[deploy_saml_auth]', :immediately	
end

	execute 'extract_saml_auth' do
		action :nothing
		command "tar xvf samlAuth.tar"
		cwd "/etc/chef"
	end

	execute 'maven_saml_auth' do
		action :nothing
		command 'mvn package'
		cwd "/etc/chef/samlAuth"
	end
	
	execute 'deploy_saml_auth' do
		action :nothing
		command "cp /etc/chef/samlAuth/target/guacamole-auth-saml-mellon-0.8.0.jar /var/lib/tomcat/webapps/guacamole/WEB-INF/classes"
	end	

['guacd', 'tomcat', 'httpd'].each do |serv|
	service serv do
		action :restart
	end
end

#########
# Cleanup
#########
