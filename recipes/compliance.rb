
###################################################
# Controls definition for chef analytics and notification
###################################################

control_group 'guacamole_mod_auth_mellon_conf_install_group' do	
	control 'liblasso3' do
		it 'should be installed' do
			expect(package('liblasso3')).to be_installed
		end
	end
	control 'autoconf' do
		it 'should be installed' do
			expect(package('autoconf')).to be_installed
		end
	end	
end

control_group 'guacamole_apache2_conf_install_group' do	
	control 'apache2' do
		let(:apache_cert_file) {"/etc/apache2/ssl/#{node['mod_auth_mellon']['base_url']}.crt"}
		let(:apache_key_file) {"/etc/apache2/ssl/#{node['mod_auth_mellon']['base_url']}.key"}
		let(:apache_ssl_file) {'/etc/apache2/sites-available/default-ssl.conf'}
		it 'should be installed and configured' do
			expect(package('apache2')).to be_installed
		end
		it 'should be running' do
			expect(service('apache2')).to be_running
		end
		it 'should have a certificate' do
			expect(file(apache_cert_file)).to be_file
		end
		it 'should have a key' do
			expect(file(apache_key_file)).to be_file
		end		
		it 'should have ssl active' do
			expect(file(apache_ssl_file)).to contain('SSLEngine on')
		end	
		it 'should have an ssl certificate configured' do
			expect(file(apache_ssl_file)).to contain("SSLCertificateFile #{"/etc/apache2/ssl/#{node['mod_auth_mellon']['base_url']}.crt"}")
		end			
		it 'should have an ssl certificate key configured' do
			expect(file(apache_ssl_file)).to contain("SSLCertificateKeyFile #{"/etc/apache2/ssl/#{node['mod_auth_mellon']['base_url']}.key"}")
		end			
	end
end


###################################################
# Controls definition for chef analytics and notification
###################################################
control_group 'guacamole_main_install_group' do	
	control 'libcairo2-dev' do
		it 'should be installed' do
			expect(package('libcairo2-dev')).to be_installed
		end
	end
	control 'libpng12-dev' do
		it 'should be installed' do
			expect(package('libpng12-dev')).to be_installed
		end
	end
	control 'libossp-uuid-dev' do
		it 'should be installed' do
			expect(package('libossp-uuid-dev')).to be_installed
		end
	end	
	control 'libfreerdp-dev' do
		it 'should be installed' do
			expect(package('libfreerdp-dev')).to be_installed
		end
	end		
	control 'libpango1.0-dev' do
		it 'should be installed' do
			expect(package('libpango1.0-dev')).to be_installed
		end
	end	
	control 'libssh2-1-dev' do
		it 'should be installed' do
			expect(package('libssh2-1-dev')).to be_installed
		end
	end	
	control 'libtelnet-dev' do
		it 'should be installed' do
			expect(package('libtelnet-dev')).to be_installed
		end
	end	
	control 'libvncserver-dev' do
		it 'should be installed' do
			expect(package('libvncserver-dev')).to be_installed
		end
	end	
	control 'libpulse-dev' do
		it 'should be installed' do
			expect(package('libpulse-dev')).to be_installed
		end
	end	
	control 'libssl-dev' do
		it 'should be installed' do
			expect(package('libssl-dev')).to be_installed
		end
	end	
	control 'libvorbis-dev' do
		it 'should be installed' do
			expect(package('libvorbis-dev')).to be_installed
		end
	end	
	control 'Libtool' do
		it 'should be installed' do
			expect(package('libtool')).to be_installed
		end
	end	
	control 'Tomcat7' do
		it 'should be installed' do
			expect(package('tomcat7')).to be_installed
		end
	end		
	control 'tomcat config' do
		let(:war_file) {'/var/lib/tomcat7/webapps/guacamole.war'}
		it 'should exist' do
			expect(file(war_file)).to be_file			
		end
	end
	control 'guacamole properties' do
		let(:guac_dir) {'/etc/guacamole'}
		let(:guac_properties) {'/etc/guacamole/guacamole.properties'}
		let(:guac_tomcat_dir) {'/usr/share/tomcat7/.guacamole'}
		let(:guac_tomcat_properties) {'/usr/share/tomcat7/.guacamole/guacamole.properties'}
		it 'should exist with properties file' do
			expect(file(guac_dir)).to be_directory
			expect(file(guac_tomcat_dir)).to be_directory	
			expect(file(guac_properties)).to be_file
			expect(file(guac_properties)).to be_mode(0755)
			expect(file(guac_properties)).to be_linked_to(guac_tomcat_properties)	
		end		
	end
	control 'link freerdp' do
		let(:guac_dir) {'/usr/local/lib/freerdp/guac'}
		let(:lib_dir) {'/usr/lib/x86_64-linux-gnu/freerdp/'}
		it 'should be linked' do
			expect(file(guac_dir)).to be_linked_to(lib_dir)
		end		
	end
	control 'openssh-server' do
		it 'should be installed' do
			expect(package('openssh-server')).to be_installed
		end
	end		
	control 'guacamole jar' do
		let(:jar_location) {"#{default['guacamole']['lib_directory']}/guacamole-auth-saml-mellon-0.8.0.jar"}
		it 'should exist' do
			expect(file(jar_location)).to be_file
		end
	end
	control 'default-jdk' do
		it 'should be installed' do
			expect(package('default-jdk')).to be_installed
		end
	end
	control 'JAVA_HOME path' do
		let(:bashrc_file) {'#{home_dir}/.bashrc'}
		let(:home_path) {"JAVA_HOME=\"#{node['java']['home_path']}\""}		
		it 'should be updated' do
			expect(file(bashrc_file)).to contain(home_path)
		end
	end
	
end