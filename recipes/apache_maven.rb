directory "/etc/maven" do
	action :create
end

cookbook_file "/etc/chef/apache-maven-3.3.3-bin.tar.gz" do
	source "apache-maven-3.3.3-bin.tar.gz"
	action :create
	notifies :run, 'execute[extract_maven]', :immediately
	notifies :run, 'execute[move_maven]', :immediately
end

	execute 'extract_maven' do
		command "tar xzvf apache-maven-3.3.3-bin.tar.gz"
		cwd "/etc/chef"
	end
	
	execute 'move_maven' do
		command 'mv apache-maven-3.3.3 /etc/maven'
		cwd '/etc/chef'
	end