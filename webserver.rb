#!/usr/bin/env ruby

# Name:         parsec webserver (Explorer Parser)
# Version:      0.0.3
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
require 'tilt/erb'
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

$exp_dir       = Dir.pwd+"/explorers"
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
  erb :help
end

# handle 404

not_found do
  erb :help
end

# handle requests

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
  $masked = 0
  @array = get_explorer_file_list(search_model,search_date,search_year,search_name)  
  erb :files
end

get '/list' do
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
  if params['host']
    search_name  = params['host']
  else
    search_name = ""
  end
  @array = list_explorers(search_model,search_date,search_year,search_name)
  erb :list
end


get '/report' do
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
  if params['host']
    $search_name  = params['host']
  else
    $search_name = ""
  end
  report     = ""
  file_array = get_explorer_file_list(search_model,search_date,search_year,$search_name) 
  file_name  = file_array[0]
  $exp_file  = file_name
  @array = config_report(report,$search_name)
  erb :report
end

