#!/usr/bin/bash

id=`id -u`

if [ $id == 0 ]; then
	echo "Running as root"
	echo "Installing required packages"
	pkg install ruby
	pkg install gcc
	pkg install imagemagick
	pkg install pigz
	pkg install wget
	pkg install pkg-config
	pkg install git
else
	echo "Not running as root"
	echo "Require sudo password to install packages"
	sudo -Sv
	sudo sh -c "pkg install ruby"
	sudo sh -c "pkg install gcc"
	sudo sh -c "pkg install imagemagick"
	sudo sh -c "pkg install pigz"
	sudo sh -c "pkg install wget"
	sudo sh -c "pkg install pkg-config"
	sudo sh -c "pkg install git"
fi	
