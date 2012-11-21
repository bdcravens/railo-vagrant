# Make sure Ubuntu up-to-date
execute "apt-get update" do
  action :run
end

# install Tomcat
package "tomcat7" do
	action :install
end

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
execute "chown tomcat7:tomcat7 . -R" do
	action :run
	user "root"
	cwd "/tmp/railo-3.3.4.003-jars"
end

# move jars to tomcat
execute "mv * /var/lib/tomcat7/common" do
	action :run
	creates "/var/lib/tomcat7/common/railo.jar"
	user "root"
	cwd "/tmp/railo-3.3.4.003-jars"
end

# update Tomcat web.xml
template "/var/lib/tomcat7/conf/web.xml" do
   source "web.xml.erb"
   mode 0644
   owner "root"
   group "tomcat7"
end

service "tomcat7" do
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
template "/var/lib/tomcat7/conf/server.xml" do
   source "server.xml.erb"
   mode 0644
   owner "root"
   group "tomcat7"
end

# restart Tomcat
service "tomcat7" do
  action :restart
end





# run admin.cfm
http_request "null" do
  url "http://#{node[:railo][:hostname]}:8080/_admin.cfm"
end


# delete _admin.cfm
file "/var/www-code/_admin.cfm" do
  action :delete
  user "root"
end


# left some specific steps you might want for you app in - commented out below


# ensure git installed
#package "git"


# copy ColdBox to /tmp so we can work with it
# directory "/tmp/coldbox" do
# 	action :create
# end
# git "/tmp/coldbox" do
#   repository "git://github.com/ColdBox/coldbox-platform.git"
#   reference "master"
#   action :sync
# end




