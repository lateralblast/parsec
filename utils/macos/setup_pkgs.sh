#!/usr/bin/bash

id=`id -u`

if [ $id == 0 ]; then
	echo "Running as root"
	echo "Installing required packages"
	brew install ruby
	brew install libxml2
	brew link -f libxml2
	brew install gcc
	brew install imagemagick
	brew install pigz
	brew install wget
	brew install pkg-config
	brew install git
else
	echo "Not running as root"
	echo "Require sudo password to install packages"
	sudo -Sv
	sudo sh -c "brew install ruby"
	sudo sh -c "brew install libxml2"
	sudo sh -c "brew link -f libxml2"
	sudo sh -c "brew install gcc"
	sudo sh -c "brew install imagemagick"
	sudo sh -c "brew install pigz"
	sudo sh -c "brew install wget"
	sudo sh -c "brew install pkg-config"
	sudo sh -c "brew install git"
fi	
