#!/usr/bin/bash

sudo apt update && sudo apt upgrade
sudo apt install net-tools
sudo apt install mlocate
sudo apt install git
sudo apt install vim
sudo apt install python3-pip

sudo adduser jay
sudo usermod -aG sudo jay


echo '10.240.0.1 jayu22' | sudo tee -a /etc/hosts > /dev/null
sudo su - jay
mkdir .ssh; cd .ssh
rsync -av jay@jayu22:~/.ssh/id_ed25519.pub .
mv id_ed25519.pub authorized_keys

cd /home/jay
git clone https://github.com/jazzlyj/dotfiles.git
cp /home/jay/dotfiles/.bash_aliases /home/jay
cp /home/jay/dotfiles/.profile.local /home/jay
echo . ~/.profile.local >> /home/jay/.profile
. .profile.local