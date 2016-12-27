#!/bin/bash

id=`id -u`

if [ $id == 0 ]; then
	echo "Running as root"
	echo "Installing required gems"
	gem install getopt --no-document
	gem install iconv --no-document
	gem install fileutils --no-document
	gem install hex_string --no-document
	gem install terminal-table --no-document
	gem install unpack --no-document
	gem install enumerate --no-document
	gem install prawn --no-document
	gem install prawn-table --no-document
	gem install fastimage --no-document
	gem install nokogiri --no-document -- --use-system-libraries
	gem install rmagick --no-document
	gem install sinatra --no-document
	gem install bcrypt --no-document
else
	echo "Not running as root"
	echo "Using sudo password to install gems"
	sudo -Sv
	sudo sh -c "gem install getopt --no-document"
	sudo sh -c "gem install iconv --no-document"
	sudo sh -c "gem install fileutils --no-document"
	sudo sh -c "gem install hex_string --no-document"
	sudo sh -c "gem install terminal-table --no-document"
	sudo sh -c "gem install unpack --no-document"
	sudo sh -c "gem install enumerate --no-document"
	sudo sh -c "gem install prawn --no-document"
	sudo sh -c "gem install prawn-table --no-document"
	sudo sh -c "gem install fastimage --no-document"
	sudo sh -c "gem install nokogiri --no-document -- --use-system-libraries"
	sudo sh -c "gem install rmagick --no-document"
	sudo sh -c "gem install sinatra --no-document"
	sudo sh -c "gem install bcrypt --no-document"
fi

