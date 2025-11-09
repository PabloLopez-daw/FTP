
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"
  config.vm.hostname = "ftp-server"
  config.vm.network "private_network", ip: "192.168.56.105"
  config.vm.network "forwarded_port", guest: 21, host: 2121
  config.vm.synced_folder ".", "/vagrant"  
  config.vm.provision "shell", path: "bootstrap.sh"
end
