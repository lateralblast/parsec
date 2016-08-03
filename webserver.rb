#!/usr/bin/env ruby

# Name:         parsec webserver (Explorer Parser)
# Version:      0.0.1
# Release:      1
# License:      CC-BA (Creative Commons By Attribution)
#               http://creativecommons.org/licenses/by/4.0/legalcode
# Group:        System
# Source:       N/A
# URL:          http://lateralblast.com.au/
# Distribution: UNIX
# Vendor:       Lateral Blast
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  Ruby script for processing explorer

# Load required gems

require 'rubygems'

begin
  require 'sinatra'
rescue LoadError
  install_gem("sinatra")
end

# Set defaults

$exp_dir = Dir.pwd+"/explorers"
$output_format = "html"

set :port, 9494

def install_gem(gem_name)
  puts "Information:\tInstalling #{gem_name}"
  %x[gem install #{gem_name}]
  Gem.clear_paths
  return
end

# Get version

def get_version()
  file_array = IO.readlines $0
  version    = file_array.grep(/^# Version/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  packager   = file_array.grep(/^# Packager/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  name       = file_array.grep(/^# Name/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  return version,packager,name
end

# Print script version information

def print_version()
  (version,packager,name) = get_version()
  puts name+" v. "+version+" "+packager
  exit
end

# Load methods

if Dir.exist?("./methods")
  file_list = Dir.entries("./methods")
  for file in file_list
    if file =~ /rb$/
      require "./methods/#{file}"
    end
  end
end

get '/files' do
  if params['model']
    search_model = params['model']
  else
    search_model = ""
  end
  if params['date']
    search_date  = params['date']
  else
    search_date = ""
  end
  if params['year']
    search_year  = params['year']
  else
    search_year = ""
  end
  if params['name']
    search_name  = params['name']
  else
    search_name = ""
  end
  exp_list = get_explorer_file_list(search_model,search_date,search_year,search_name)  
  exp_list.each do |line|
    "#{line}"
  end
end
