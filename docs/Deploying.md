Deploying Adefy
===============

We are using [Fabric](http://docs.fabfile.org/en/1.8/) for deployment and server
automation. `fabfile.py` handles everything.

Dependencies & Preparation
--------------------------
For obvious reasions, Fabric is required. Fabric needs python 2.7, and can be
installed with `pip`.

On debian-based systems:
* pip: `sudo apt-get install python-pip`
* fabric: `sudo pip install fabric`

On arch:
* pip: `sudo pacman -S python2-pip`
* fabric: `sudo pip install fabric`

On windows:
* `No idea, google around`

Deploying
---------
The fabfile is invoked with `fab [command]`. Available commands are:

* `setup_staging`: Prepare staging server(s). Re-creates the remote directory
* `setup_production`: Prepare production server(s). Re-creates the remote directory

* `deploy`: Update & rebuild production branch on all production servers
* `stage`: Update & rebuild staging branch on all staging servers

* `status`: Check the status of node processes on all servers
* `update_servers`: Check for and install package updates on all servers

* `stage_up`: Start the node process on all staging servers
* `stage_restart`: Restart the node process on all staging servers
* `stage_down`: Stop the node process on all staging servers

* `production_up`: Start the node process on all production servers
* `production_restart`: Restart the node process on all production servers
* `production_down`: Stop the node process on all production servers