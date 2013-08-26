# Make sure Ubuntu up-to-date
execute "apt-get update" 

# install Apache 2
package "apache2" do
  action :install
end

# Download Railo 
remote_file "/opt/files/railo-#{node[:railo_version]}-pl2-linux-x64-installer.run" do
  source "http://www.getrailo.org/railo/remote/download/#{node[:railo_version]}/tomcat/linux/railo-#{node[:railo_version]}-pl2-linux-x64-installer.run"
  action :create_if_missing
  mode "0777"
  owner "root"
  group "root"
end
# install Railo
execute "./railo-#{node[:railo_version]}-pl2-linux-x64-installer.run --mode unattended --tomcatpass #{node[:railo_password]}" do
  action :run
  user "root"
  cwd "/opt/files/"
  creates "/opt/railo/railo_ctl"
end


# install mysql
package "mysql-server" do
  action :install
end
package "mysql-client" do
  action :install
end

# set MySQL password
execute "mysqladmin -u root -h localhost password '#{node[:mysql_password]}' && touch .mysql_password_set" do
  action :run
  user "root"
  cwd "/opt/files"
  creates "/opt/files/.mysql_password_set"
end
# create database
execute "mysql -u root -p#{node[:mysql_password]} -e 'create database vagrant_db;' && touch .mysql_db_created" do
  action :run
  user "root"
  cwd "/opt/files"
  creates "/opt/files/.mysql_db_created"
end



# apache config
template "/etc/apache2/sites-available/default" do
   source "default.erb"
   mode 0644
   owner "root"
   group "root"
end
# restart Apache
service "apache2" do
  action :restart
end