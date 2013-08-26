# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|  
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"  
  config.vm.network :private_network, ip: "10.10.10.50"   
  Dir.mkdir("./site") unless File.directory?("./site")
  config.vm.synced_folder "./site", "/var/website", extra: 'dmode=777,fmode=777'
  Dir.mkdir("./files") unless File.directory?("./files")
  config.vm.synced_folder "./files", "/opt/files"
  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "./cookbooks"
    chef.add_recipe "main"  
    chef.json = JSON.parse(File.read("cookbooks/node.json")) 
  end 
end
