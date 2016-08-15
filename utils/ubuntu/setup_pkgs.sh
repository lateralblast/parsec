#!/bin/bash

id=`id -u`

if [ $id == 0 ]; then
  echo "Running as root"
  echo "Installing required packages"
  apt-get install -y ruby
  apt-get install -y gcc
  apt-get install -y imagemagick
  apt-get install -y libxml2
  apt-get install -y pigz
  apt-get install -y wget
  apt-get install -y pkg-config
  apt-get install -y git
  if [ "`uname -p`" == "x86_64" ]; then
    wget -O /tmp/star.deb https://launchpad.net/ubuntu/+source/star/1.5final-2ubuntu2/+build/1586990/+files/star_1.5final-2ubuntu2_amd64.deb
  else
    wget -O /tmp/star.deb https://launchpad.net/ubuntu/+source/star/1.5final-2ubuntu2/+build/1586992/+files/star_1.5final-2ubuntu2_i386.deb
  fi
  dpkg -i /tmp/star.deb
else
  echo "Not running as root"
  echo "Require sudo password to install packages"
  sudo -Sv
  sudo sh -c "apt-get install -y ruby"
  sudo sh -c "apt-get install -y gcc"
  sudo sh -c "apt-get install -y imagemagick"
  sudo sh -c "apt-get install -y libxml2"
  sudo sh -c "apt-get install -y pigz"
  sudo sh -c "apt-get install -y wget"
  sudo sh -c "apt-get install -y pkg-config"
  sudo sh -c "apt-get install -y git"
  if [ "`uname -p`" == "x86_64" ]; then
    wget -O /tmp/star.deb https://launchpad.net/ubuntu/+source/star/1.5final-2ubuntu2/+build/1586990/+files/star_1.5final-2ubuntu2_amd64.deb
  else
    wget -O /tmp/star.deb https://launchpad.net/ubuntu/+source/star/1.5final-2ubuntu2/+build/1586992/+files/star_1.5final-2ubuntu2_i386.deb
  fi
  dpkg -i /tmp/star.deb
fi  
