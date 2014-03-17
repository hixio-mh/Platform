VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "platform-docker" do |platform|
    platform.vm.box = "docker-precise64"
    platform.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/ubuntu-12.04.3-amd64-vbox.box"

    platform.ssh.forward_agent = true
    platform.vm.network :private_network, ip: "192.168.100.11"

    platform.vm.provision :ansible do |ansible|
      ansible.playbook = "provisioning/deploys/vagrant.yml"
      ansible.inventory_path = "provisioning/hosts"
    end

    platform.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "2"]
    end
  end

end
