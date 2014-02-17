# Development

Vagrant & Ansible are pretty sweet. It takes just a few minutes to get up and running.

An even more optimal variant would be using [a docker provider for Vagrant](https://github.com/fgrehm/docker-provider), as docker
is more lightweight than Virtual Box.

## Setting up dnsmasq

Edit the /etc/dnsmasq.conf to include `address=/adefy.dev/192.168.113.10/`

## Setup

Install the vagrant-vbguest plugin, to automatically update the VM's Guest Additions to match the host.

```
vagrant plugin install vagrant-vbguest
```

Get the VM up!
```
vagrant up
```

The rest is just setup process, that we need to move into Ansible.
```
vagrant ssh
cd /vagrant
mongo < setup_db.js
npm install
sudo npm install -g grunt-cli
grunt full
grunt dev
```

When stopping work, use `vagrant halt` to stop the VM. Don't destroy it, or you'll need to do the last step again.
