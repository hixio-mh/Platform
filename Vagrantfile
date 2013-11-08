VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "2"]
  end

  # Adefy doesn't use SSL in dev mode!
  config.vm.network :forwarded_port, guest: 8080, host: 10080

  config.ssh.forward_agent = true

  config.vm.provision :shell, :path => "bootstrap_vagrant.sh"
end