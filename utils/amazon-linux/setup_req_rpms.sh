#!/bin/bash

id=`id -u`

if [ $id == 0 ]; then
	echo "Running as root"
	echo "Installing required RPMs"
	yum -y install git
	yum -y install gcc
	yum -y install libxml2-devel
	yum -y install libxslt-devel
	yum -y remove ruby
	yum -y install ruby23
	yum -y install ruby23-devel
	yum -y install ImageMagick
	yum -y install ImageMagick-devel
	yum -y install pigz
	yum -y install star
else
	echo "Not running as root"
	echo "Using sudo password to install RPMs"
	sudo -Sv
	sudo sh -c "yum -y install git"
	sudo sh -c "yum -y install gcc"
	sudo sh -c "yum -y install libxml2-devel"
	sudo sh -c "yum -y install libxslt-devel"
	sudo sh -c "yum -y remove ruby"
	sudo sh -c "yum -y install ruby23"
	sudo sh -c "yum -y install ruby23-devel"
	sudo sh -c "yum -y install ImageMagick"
	sudo sh -c "yum -y install ImageMagick-devel"
	sudo sh -c "yum -y install pigz"
	sudo sh -c "yum -y install star"
fi

