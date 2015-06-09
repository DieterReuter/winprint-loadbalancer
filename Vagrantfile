# -*- mode: ruby -*-
# vi: set ft=ruby :

# set the default provider
ENV["VAGRANT_DEFAULT_PROVIDER"] = "virtualbox"

Vagrant.configure(2) do |config|
  config.vm.box = "windows_2008_r2"
  config.vm.network :forwarded_port, :host => 8000, :guest => 8000

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true

    # Customize the amount of memory on the VM:
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.provision "shell", path: "scripts/install-role-printserver.ps1", privileged: false
  config.vm.provision "shell", path: "install/install-monitor.bat", privileged: false
  config.vm.provision "shell", path: "scripts/install-loopback-adapter.ps1", privileged: false
end
