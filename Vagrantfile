VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "redis" do |redis|
    redis.vm.box = "precise32"
    redis.vm.box_url = "http://files.vagrantup.com/precise32.box"

    redis.ssh.forward_agent = true
    redis.vm.network :private_network, ip: "192.168.100.11"

    redis.vm.provision :ansible do |ansible|
      ansible.playbook = "provisioning/redis.yml"
      ansible.inventory_path = "provisioning/hosts"
    end

    redis.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "2"]
    end
  end

  config.vm.define "mongo" do |mongo|
    mongo.vm.box = "precise32"
    mongo.vm.box_url = "http://files.vagrantup.com/precise32.box"

    mongo.ssh.forward_agent = true
    mongo.vm.network :private_network, ip: "192.168.100.12"

    mongo.vm.provision :ansible do |ansible|
      ansible.playbook = "provisioning/mongo.yml"
      ansible.inventory_path = "provisioning/hosts"
    end

    mongo.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "2"]
    end
  end

  config.vm.define "api" do |api|
    api.vm.box = "precise32"
    api.vm.box_url = "http://files.vagrantup.com/precise32.box"

    api.ssh.forward_agent = true
    api.vm.network :private_network, ip: "192.168.100.13"

    api.vm.provision :ansible do |ansible|
      ansible.playbook = "provisioning/api.yml"
      ansible.inventory_path = "provisioning/hosts"
    end

    api.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "2"]
    end
  end

end
