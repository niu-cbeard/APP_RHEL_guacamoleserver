default['guacamole']['lib_directory'] = "/var/lib/tomcat/webapps/guacamole/WEB-INF/classes"
default['guacamole']['guacd']['port'] = '4822'
default['guacamole']['auth_provider'] = 'org.glyptodon.guacamole.auth.SAMLModMellonAuthenticationProvider'
default['guacamole']['secret_key'] = 'password'
default['guacamole']['timestamp_age_limit'] = '600000'
default['guacamole']['distribution_path'] = 'guacamole-server-0.9.7'
default['guacamole']['war_file'] = 'guacamole-0.9.7.war'
default['guacamole']['jar_file'] = 'guacamole-auth-saml-mellon-0.8.0.jar'

default['guacamole']['distribution_file_name'] = 'guacamole-server-0.9.7.tar.gz'

default['mod_proxy']['request_header']['x_domain'] = 'cognisec'
default['mod_proxy']['request_header']['x_password'] = '%{MELLON_password}e'
default['mod_proxy']['request_header']['x_username'] = '%{MELLON_username}e'
default['mod_proxy']['request_header']['x_groups'] = '%{MELLON_groups}e'
default['mod_proxy']['request_header']['x_upn'] = '%{MELLON_upn}e'
default['mod_proxy']['proxy_pass_reverse_cookie_path'] = '/guacamole-0.9.7/ /guacamole/'

default['mod_auth_mellon']['module_location'] = '/usr/lib/apache2/modules/mod_auth_mellon.so'
default['mod_auth_mellon']['base_url'] = 'gu.cognisec.biz'
default['mod_auth_mellon']['cert_name'] = 'gu.cognisec.biz'
default['mod_auth_mellon']['metadata_location'] = 'mellon'
default['mod_auth_mellon']['identity_provider']['metadata_file'] = 'idp-metadata.xml'
default['mod_auth_mellon']['endpoint_path'] = '/mellon'
default['mod_auth_mellon']['logout_endpoint'] = '/logout'
default['mod_auth_mellon']['response_endpoint'] = '/postResponse'
default['mod_auth_mellon']['ssl_directory'] = 'ssl'

default['java']['home_path'] = '/usr/java/jdk1.7.0_79'
default['java']['jre_path'] = '/usr/java/jdk1.7.0_79/jre'

default['tomcat']['distribution_file_name'] = 'apache-tomcat-7.0.64.tar.gz'

default['wstunnel']['proxy_pass'] = 'ws://rgdev53v.dev.niu.local:8080/guacamole/websocket-tunnel'
default['wstunnel']['proxy_pass_reverse'] = 'ws://rgdev53v.dev.niu.local:8080/guacamole/websocket-tunnel'

default['yum']['additional_repositories'] = ['epel.repo', 'epel.repo.rpmnew', 'epel-apache-maven.repo', 'epel-testing.repo', 'rhel-source.repo']

default['guacamole']['freerdp_files'] = ['guacdr.la', 'guacdr.so', 'guacsnd.la', 'guacsnd.so', 'guacsvc.la', 'guacsvc.so']

default['maven']['bin_directory'] = '/etc/maven/bin'