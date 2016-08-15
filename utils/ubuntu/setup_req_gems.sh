#!/bin/bash

id=`id -u`

if [ $id == 0 ]; then
	echo "Running as root"
	echo "Installing required gems"
	gem install getopt
	gem install iconv
	gem install rmagick
	gem install fileutils
	gem install hex_string
	gem install terminal-table
	gem install unpack
	gem install enumerate
	gem install prawn
	gem install prawn-table
	gem install fastimage
	gem install nokogiri
	gem install sinatra
else
	echo "Not running as root"
	echo "Require sudo password to install gems"
	sudo -Sv
	sudo sh -c "gem install getopt"
	sudo sh -c "gem install iconv"
	sudo sh -c "gem install rmagick"
	sudo sh -c "gem install fileutils"
	sudo sh -c "gem install hex_string"
	sudo sh -c "gem install terminal-table"
	sudo sh -c "gem install unpack"
	sudo sh -c "gem install enumerate"
	sudo sh -c "gem install prawn"
	sudo sh -c "gem install prawn-table"
	sudo sh -c "gem install fastimage"
	sudo sh -c "gem install nokogiri"
	sudo sh -c "gem install sinatra"
fi
