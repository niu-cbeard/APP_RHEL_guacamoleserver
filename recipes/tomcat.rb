cookbook_file "/etc/chef/apache-tomcat-7.0.64.tar.gz" do
	sources  "apache-tomcat-7.0.64.tar.gz"	
	notifies :run, 'execute[move_tomcat]', :immediately
	notifies :run, 'execute[enable_tomcat_service]', :immediately
end

	execute 'move_tomcat' do
		command "mv apache-tomcat-7.0.64 /usr/local/tomcat"
		cwd "/etc/chef"
	end

	execute 'enable_tomcat_service' do
		command 'chkconfig tomcat on'
	end