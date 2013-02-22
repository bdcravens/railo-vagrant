# Make sure Ubuntu up-to-date
execute "apt-get update" 

# execute "apt-get upgrade -y"

# include_recipe "java:oracle"

include_recipe "apache2"
include_recipe "apache2::mod_proxy"
apache_module "proxy_ajp"

web_app "my_site" do
  template "mysite.conf.erb"
  #example of passing in a parameter
  server_name node['hostname']
end

# install Tomcat
package "#{node[:tomcat_version]}" do
  action :install
end

# include_recipe "tomcat::default"

# include_recipe "mysql"
# include_recipe "mysql::server"

# install git for source control
package "git-core"

# install vim editor
package "vim"

# Download Railo JARs (http://www.getrailo.org/index.cfm/download/)
remote_file "/tmp/railo-3.3.4.003-jars.tar.gz" do
  source "http://www.getrailo.org/railo/remote/download/3.3.4.003/custom/all/railo-3.3.4.003-jars.tar.gz"
  action :create_if_missing
  mode "0744"
  owner "root"
  group "root"
end

# untar it
execute "tar xvzf railo-3.3.4.003-jars.tar.gz" do
  creates "railo-3.3.4.003-jars"
  action :run
  user "root"
  cwd "/tmp"
end

# set jar permissions
execute "chown #{node[:tomcat_version]}:#{node[:tomcat_version]} . -R" do
	action :run
	user "root"
	cwd "/tmp/railo-3.3.4.003-jars"
end

# move jars to tomcat
execute "mv * /var/lib/#{node[:tomcat_version]}/common" do
	action :run
	creates "/var/lib/#{node[:tomcat_version]}/common/railo.jar"
	user "root"
	cwd "/tmp/railo-3.3.4.003-jars"
end

# update Tomcat web.xml
template "/var/lib/#{node[:tomcat_version]}/conf/web.xml" do
   source "web.xml.erb"
   mode 0644
   owner "root"
   group "#{node[:tomcat_version]}"
end

service "#{node[:tomcat_version]}" do
  action [:enable, :start]
end

# copy index.cfm
template "/var/www-code/index.cfm" do
  source "index.cfm.erb"
  # mode 0644
  # owner "root"
  # group "root"
  action :create_if_missing
end

# copy _admin.cfm
template "/var/www-code/_admin.cfm" do
  source "_admin.cfm.erb"
  # mode 0644
  # owner "root"
  # group "root"
end

# hosts file
template "/etc/hosts" do
   source "hosts.erb"
   mode 0644
   owner "root"
   group "root"
end

# copy server.xml
template "/var/lib/#{node[:tomcat_version]}/conf/server.xml" do
   source "server.xml.erb"
   mode 0644
   owner "root"
   group "#{node[:tomcat_version]}"
end

# restart Apache
service "apache2" do
  action :restart
end

# restart Tomcat
service "#{node[:tomcat_version]}" do
  action :restart
end

# run admin.cfm
http_request "null" do
  url "http://#{node[:railo][:hostname]}/_admin.cfm"
end

# delete _admin.cfm
file "/var/www-code/_admin.cfm" do
  action :delete
  user "root"
end

# remove archive from install folder
execute "rm" do
  command "rm -i /tmp/railo-3.3.4.003-jars.tar.gz" 
  action :run
end

# left some specific steps you might want for you app in - commented out below

if node.attribute?('coldfusion_framework')

  case node[:platform]
  when "coldbox"
    directory "/tmp/coldbox" do
      action :create
    end
    git "/tmp/coldbox" do
      repository "git://github.com/ColdBox/coldbox-platform.git"
      reference "master"
      action :sync
    end
  when "fw1"
    # do this
  when "cfwheels"
    # do this
  end 
end