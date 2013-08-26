A totally new version of railo-vagrant. Major changes:

* uses Vagrant 1.2+ (should work in 1.1+ - will work in 1.0.x with some modification to Vagrantfile)
* rather than install Tomcat and then install Railo jars, uses command line installer which uses embedded Tomcat
* simplified recipe: doesn't include pre-built recipes, but does everything in the recipe. Perhaps this will change, but for me, this seems the simplest way to get a dev VM up and running fast ....

Steps to run:
* Install latest version of VirtualBox and Vagrant
* git clone this project
* from directory where you cloned, run the following:

```
vagrant up
```
* access the site at 10.10.10.50 (change this in the Vagrantfile if you need to)

By default, it launches with little memory (384mb?). You can uncomment the provider block and update this if need be.

Should persist across restarts (vagrant reload, vagrant suspend). Delete mysql dotfiles in ./files if you need to regen the mysql database. Delete railo install file to force redownload (in ./files). Delete the ./site directory if you want to recreate it.

Drop all your code in ./site (will be created if it doesn't exist). 
Update cookbooks/node.json to change Railo version (defaults to 4.0.4.001) and MySQL and Railo passwords (defaults to "vagrant")

Apache is stock. To enable things like URL rewriting, ssh in like on any other Ubuntu setup and update it. (This is an area where using the apache recipe might be a good idea for future revisions)
(vagrant ssh on OSX/Linux; on Windows, you'll need to ssh to IP using "insecure_private_key" file that comes with your Vagrant install)