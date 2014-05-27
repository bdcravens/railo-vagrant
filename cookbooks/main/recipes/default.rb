# Run apt-get update to create the stamp file
execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
  not_if do ::File.exists?('/var/lib/apt/periodic/update-success-stamp') end
  action :nothing
end

# For other recipes to call to force an update
execute "apt-get update" do
  command "apt-get update"
  ignore_failure true
  action :nothing
end

# provides /var/lib/apt/periodic/update-success-stamp on apt-get update
package "update-notifier-common" do
  notifies :run, resources(:execute => "apt-get-update"), :immediately
end

execute "apt-get-update-periodic" do
  command "apt-get update"
  ignore_failure true
  only_if do
    File.exists?('/var/lib/apt/periodic/update-success-stamp') &&
    File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
  end
end

include_recipe "mysql::server"
# include_recipe "tomcat::default"
include_recipe "database::mysql"
include_recipe 'git'
include_recipe 'vim'
include_recipe "apache2"
include_recipe "apache2::mod_proxy"
apache_module "proxy_ajp"

web_app "my_site" do
  template "mysite.conf.erb"
  #example of passing in a parameter
  server_name node['hostname']
end

# install Tomcat
package "tomcat#{node[:tomcat_version]}" do
  action :install
end

# create a mysql database
mysql_database 'oracle_rules' do
  connection ({:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']})
  action :create
end

# Download Railo JARs (http://www.getrailo.org/index.cfm/download/)
remote_file "/tmp/railo-#{node[:railo_version]}-jars.tar.gz" do
  source "http://www.getrailo.org/railo/remote/download42/#{node[:railo_version]}/custom/all/railo-#{node[:railo_version]}-jars.tar.gz"
  action :create_if_missing
  mode "0744"
  owner "root"
  group "root"
end
    
# untar it
execute "tar xvzf railo-#{node[:railo_version]}-jars.tar.gz" do
  creates "railo-#{node[:railo_version]}-jars"
  action :run
  user "root"
  cwd "/tmp"
end

# set jar permissions
execute "chown tomcat#{node[:tomcat_version]}:tomcat#{node[:tomcat_version]} . -R" do
  action :run
  user "root"
  cwd "/tmp/railo-#{node[:railo_version]}-jars"
end

# move jars to tomcat
execute "mv * /var/lib/tomcat#{node[:tomcat_version]}/common" do
  action :run
  creates "/var/lib/tomcat#{node[:tomcat_version]}/common/railo.jar"
  user "root"
  cwd "/tmp/railo-#{node[:railo_version]}-jars"
end

# update Tomcat web.xml
template "/var/lib/tomcat#{node[:tomcat_version]}/conf/web.xml" do
   source "web.xml.erb"
   mode 0644
   owner "root"
   group "tomcat#{node[:tomcat_version]}"
end

service "tomcat#{node[:tomcat_version]}" do
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
template "/var/lib/tomcat#{node[:tomcat_version]}/conf/server.xml" do
   source "server.xml.erb"
   mode 0644
   owner "root"
   group "tomcat#{node[:tomcat_version]}"
end

# restart Apache
service "apache2" do
  action :restart
end

# restart Tomcat
service "tomcat#{node[:tomcat_version]}" do
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

# add your framework option
if node.attribute?('coldfusion_framework')
  package "zip"

  case "#{node[:coldfusion_framework]}"
  when "coldbox"
    execute "wget -O /tmp/framework.zip http://www.coldbox.org/download/coldbox/standalone/true" do
      action :run
      user "root"
      cwd "/tmp"
    end
  when "fw1"
    #to this git://github.com/seancorfield/fw1.git
  when "cfwheels"
    execute "wget -O /tmp/framework.zip http://cfwheels.org/download/latest-version" do
      action :run
      user "root"
      cwd "/tmp"
    end
    #to wget http://cfwheels.org/download/latest-version
  end

  # untar it
  execute "unzip -o framework.zip -d /vagrant/code" do
    creates "code"
    action :run
    user "root"
    cwd "/tmp"
  end

  # set permissions
  execute "chown -R 777 code" do
    action :run
    user "root"
    cwd "/vagrant"
  end
end
