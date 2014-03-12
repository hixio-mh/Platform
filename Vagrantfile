VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "platform" do |platform|
    platform.vm.box = "precise32"
    platform.vm.box_url = "http://files.vagrantup.com/precise32.box"

    platform.ssh.forward_agent = true
    platform.vm.network :private_network, ip: "192.168.100.11"

    platform.vm.provision :ansible do |ansible|
      ansible.playbook = "provisioning/playbooks/vagrant.yml"
      ansible.inventory_path = "provisioning/hosts"
    end

    platform.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "2"]
    end
  end

end
