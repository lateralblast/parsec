#!/usr/bin/env ruby

# Name:         parsec webserver (Explorer Parser)
# Version:      0.0.5
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
require 'pathname'
require 'etc'
require 'date'

def install_gem(gem_name)
  puts "Information:\tInstalling #{gem_name}"
  %x[gem install #{gem_name}]
  Gem.clear_paths
  return
end

begin
  require 'sinatra'
rescue LoadError
  install_gem("sinatra")
end
begin
  require 'fileutils'
rescue LoadError
  install_gem("fileutils")
end
begin
  require 'hex_string'
rescue LoadError
  install_gem("hex_string")
end
begin
  require 'unpack'
rescue LoadError
  install_gem("unpack")
end
begin
  require 'enumerator'
rescue LoadError
  install_gem("enumerator")
end
begin
  require 'iconv'
rescue LoadError
  install_gem("iconv")
end

# Set global variables

$script_name   = "Parsec"
$verbose       = 0
$base_dir      = ""
$do_disks      = 0
$host_info     = {}
$sys_config    = {}
$exp_file_list = []
$masked        = 0
$exp_file      = ""
$exp_dir       = ""

# Set defaults
# Unlike the reporting script, these currently don't get auto detected

$work_dir      = "/tmp"
$output_format = "html"
$output_file   = ""

set :port, 9494

# Load methods

if Dir.exist?("./methods")
  file_list = Dir.entries("./methods")
  for file in file_list
    if file =~ /rb$/
      require "./methods/#{file}"
    end
  end
end

# setup config

check_local_config()

# handle /

get '/' do
  head  = File.readlines("./views/layout.html")
  body  = File.readlines("./views/help.html")
  array = head + body
  "#{array.join}"
end

# handle 404

not_found do
  head  = File.readlines("./views/layout.html")
  body  = File.readlines("./views/help.html")
  array = head + body
  "#{array.join}"
end

# List explorers

get '/list' do
  if params['example']
    $exp_dir = Dir.pwd+"/examples"
  else
    $exp_dir = Dir.pwd+"/explorers"
  end
  if params['masked']
    if params['masked'].to_s.downcase.match(/true|1/)
      $masked = 1
    else
      $masked = 0
    end
  else
    $masked = 0
  end
  if params['report']
    $report_type = params['report']
  else
    $report_type = "all"
  end
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
  if params['server']
    search_name  = params['server']
  else
    search_name = ""
  end
  head  = File.readlines("./views/layout.html")
  body  = list_explorers(search_model,search_date,search_year,search_name)
  array = head + body
  "#{array.join}"
end

# Do report

get '/report' do
  if params['example']
    $exp_dir = Dir.pwd+"/examples"
  else
    $exp_dir = Dir.pwd+"/explorers"
  end
  if params['masked']
    if params['masked'].to_s.downcase.match(/true|1/)
      $masked = 1
    else
      $masked = 0
    end
  else
    $masked = 0
  end
  if params['report']
    $report_type = params['report']
  else
    $report_type = "all"
  end
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
  if params['server']
    search_name  = params['server']
  else
    search_name = ""
  end
  report     = ""
  file_array = get_explorer_file_list(search_model,search_date,search_year,search_name) 
  file_name  = file_array[0]
  $exp_file  = file_name
  head  = File.readlines("./views/layout.html")
  body  = config_report(report,search_name)
  array = head + body
  "#{array.join}"
end

