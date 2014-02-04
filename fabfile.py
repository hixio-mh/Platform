# Fabric deploy script
#
# Install pip with:    sudo apt-get install python-pip
# Install fabric with: sudo pip install fabric
from __future__ import with_statement
from fabric.api import *

env.roledefs = {
  "staging": ["staging.adefy.com:7374"],
  "production": ["app1.adefy.com:7374"]
}

env.user = "cris"
env.key_filename = "~/.ssh/id_rsa"

adefy_path = "/var/adefy/"
adefy_repo = "git@bitbucket.org:spectrumit/adefyplatform.git"

# Sets up the environment and folder on the remote server
def _setup(branch):
  with cd(adefy_path):

    # Clean and initialize repo
    run("rm * .git .gitignore .gitmodules -rf")
    run("git init .")
    run("git remote add origin " + adefy_repo)
    run("git pull origin master")

    run("git branch " + branch)
    run("git pull origin " + branch)

    # Install global dependencies
    sudo("npm install -g grunt-cli pm2")

# Updates server packages
@roles("production", "staging")
def update_servers():
  sudo("bash -c 'apt-get update && apt-get upgrade'")

# Production
@roles("production")
def setup_production():
  _setup("production")

@roles("production")
def deploy():
  with cd(adefy_path):

    # Update
    # run("git checkout production")
    run("git stash")
    run("git pull origin production")
    run("git stash pop")

    # Install any new modules
    run("npm install")

    # Test (abort on fail)
    run("grunt stageTest")

    # Deploy
    run("grunt deploy")

    # Restart
    run("pm2 reload buildProduction/adefy.js")

# Staging
@roles("staging")
def setup_staging():
  _setup("staging")

@roles("staging")
def stage():
  with cd(adefy_path):

    # Update
    run("git checkout staging")
    run("git pull origin staging")

    # Install any new modules
    run("npm install")

    # Test (abort on fail)
    run("grunt stageTest")

    # Stage
    run("grunt stage")

    # Restart
    run("pm2 reload buildStaging/adefy.js")

# Forever controls
@roles("staging")
def stage_up():
  with cd(adefy_path):
    run("pm2 start buildStaging/adefy.js -i 8")

@roles("staging")
def stage_restart():
  with cd(adefy_path):
    run("pm2 reload staging/adefy.js")

@roles("staging")
def stage_down():
  with cd(adefy_path):
    run("pm2 stop buildStaging/adefy.js")

@roles("production")
def production_up():
  with cd(adefy_path):
    run("pm2 start buildProduction/adefy.js -i 8")

@roles("production")
def production_restart():
  with cd(adefy_path):
    run("pm2 reload buildProduction/adefy.js")

@roles("production")
def production_down():
  with cd(adefy_path):
    run("pm2 stop buildProduction/adefy.js")

@roles("production", "staging")
def status():
  with cd(adefy_path):
    run("pm2 list")
