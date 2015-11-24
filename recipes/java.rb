
cookbook_file "/etc/chef/jdk-7u79-linux-x64.rpm" do
	source "jdk-7u79-linux-x64.rpm"
	action :create
	notifies :run, 'execute[deploy_java_jdk]', :immediately
end

#execute "rpm -ivh jre-7u79-linux-x64.rpm" do
#	command "rpm -ivh jre-7u79-linux-x64.rpm"
#	cwd "/etc/chef"
#end

	execute 'deploy_java_jdk' do
		command "rpm -ivh jdk-7u79-linux-x64.rpm"
		cwd "/etc/chef"	
	end