cfme-cmd-tools
==============

The intent of this project is to provide a set of command line tools for Cloudforms


Installation
============

CREATE YOUR GIT FOLDER ON YOUR CLOUDFORMS APPLIANCE:
mkdir /git

PULL THIS PROJECT INTO YOUR GIT FOLDER
cd /git
git clone https://github.com/mberube9/cfme-cmd-tools.git

ADD THE COMMAND LINE TOOLS IN YOUR PATH (OPTIONAL)
export PATH=$PATH:/git/cfme-cmd-tools

UPDATE THE AUTOMATE CONFIGURATION FILE WITH YOUR SETTINGS
vi /git/cfme-cmd-tools/automate.yaml


Automate
========

Automate is a command line tool to push or pull your Cloudforms automate model to a git repo.  

syntax:
   automate  [provide list of available commands]
   automate dsdump  [dump your automate model in a temporary folder: default = /git/temp]
   automate git-pull  [pull your automate domain from git and rsync it to your Cloudforms datastore]
   automate git-push  [pull your automate domain from Cloudforms and rsync it to your git repo]
   



