#!/bin/bash
sudo apt-get -y install python3-distutils
sudo apt-get -y install python3-apt

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py --user
python3 -m pip install --user ansible

export PATH="$PATH:~/.local/bin"

ansible-playbook -i hosts.yml play2.yml
ansible-playbook -i hosts.yml play3.yml

#https://askubuntu.com/questions/842592/apt-get-fails-on-16-04-or-18-04-installing-mongodb