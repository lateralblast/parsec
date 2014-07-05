#!/usr/bin/env ruby

# Name:         parsec (Explorer Parser)
# Version:      0.4.0
# Release:      1
# License:      CC-BA (Creative Commons By Attribution)
#               http://creativecommons.org/licenses/by/4.0/legalcode
# Group:        System
# Source:       N/A
# URL:          http://lateralblast.com.au/
# Distribution: UNIX
# Vendor:       Lateral Blast
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  Ruby script wrapper for processing explorer

# Load gems

require 'rubygems'
require 'fileutils'
require 'getopt/std'
require 'pathname'
require 'hex_string'
require 'terminal-table'

options = "abcdehlmvACDEHIKLMOSVZd:f:s:w:R:o:"

# Set up some script related variables

$methods_dir     = ""
$information_dir = ""
$firmware_dir    = ""

[ "methods", "information", "firmware" ].each do |test_dir|
  required_dir = eval("$#{test_dir}_dir")
  if !required_dir.match(/[A-z]/)
    script_dir = File.basename($0)
    if !script_dir.match(/\//)
      script_dir = Dir.pwd
    end
    required_dir = script_dir+"/"+test_dir
    if !File.directory?(required_dir) or File.symlink?(required_dir)
      puts "Cannot locate "+test_dir+" directory"
      exit
    end
  end
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

# Set global variables

$work_dir      = ""
$exp_file      = ""
$exp_dir       = ""
$verbose       = 0
$base_dir      = ""
$do_disks      = 0
$host_info     = {}
$sys_config    = {}
$exp_file_list = []
$masked        = 0

# Report types

report             = {}
report["io"]       = "Report on all IO"
report["emulex"]   = "Report on Emulex FC devices"
report["qlogic"]   = "Report on Qlogic FC devices"
report["disk"]     = "Report on disks"
report["eeprom"]   = "Report on EEPROM"
report["security"] = "Report on Security settings"
report["password"] = "Report on Password settings"
report["host"]     = "Report on Host information"
report["memory"]   = "Report on Memory information"
report["cpu"]      = "Report on CPU information"
report["ldom"]     = "Report on LDom information"
#report[""]=""

# Get code name and version

def get_code_name
  code_name = $0
  code_name = Pathname.new(code_name)
  code_name = code_name.basename.to_s
  code_name = code_name.gsub(".rb","")
  return code_name
end

def get_code_ver
  code_ver = IO.readlines($0)
  code_ver = code_ver.grep(/^# Version/)
  code_ver = code_ver[0].to_s.split(":")
  code_ver = code_ver[1].to_s.gsub(" ","")
  return code_ver
end

# Print usage

def print_usage(options)
  code_name = get_code_name()
  code_ver  = get_code_ver()
  puts
  puts code_name+" v. "+code_ver
  puts
  puts "Usage: "+code_name+" -["+options+"]"
  puts
  puts "-h: Print help"
  puts "-f: Specify Explorer file to process"
  puts "-s: Specify System to process"
  puts "    (Filename will be determined if it exists)"
  puts "-A: Print all configuration information (default)"
  puts "-E: Print EEPROM configuration information"
  puts "-I: Print IO configuration information"
  puts "-H: Print Host information"
  puts "-L: Print LDom information"
  puts "-C: Print CPU configuration information"
  puts "-R: Print configuration information for a specific component"
  puts "-m: Mask data (hostnames etc)"
  puts "-d: Set Explorer directory"
  puts "-l: List explorers"
  puts "-a: Process all explorers"
  puts
  puts "Example (Display CPUs):"
  puts
  puts code_name+" -s hostanme -R cpu"
  puts
  exit
end

begin
  opt = Getopt::Std.getopts(options)
rescue
  print_usage(options)
end

# Mask data

if opt["m"]
  $masked = 1
end

# Set explorer directory

if opt["d"]
  $exp_dir = opt["d"]
else
  if !$exp_dir.match(/[A-z]/)
    $exp_dir = Dir.pwd+"/explorers"
  end
end

# List explorers

if opt["l"]
  list_explorers()
  exit
end

if opt["d"]
  $do_disks = 1
end

if opt["V"]
  code_name = get_code_name()
  code_ver  = get_code_ver()
  puts code_name+"v. "+code_ver
  exit
end

if opt["v"]
  $verbose = 1
  puts "Operating in verbose mode"
end

# Handle filename and hostname options

if opt["f"]
  $exp_file = opt["f"]
  if !File.exist?($exp_file)
    puts
    puts "Explorer File: #{$exp_file} does not exist"
    exit
  end
else
  if !opt["s"] and !opt["a"]
    puts
    puts "Explorer file or home name not specified"
    print_usage(options)
  end
  if  !opt["b"] and !$base_dir.match(/[A-z]/)
    $base_dir = Dir.pwd
  end
  $exp_dir  = $base_dir.chomp()
  $exp_dir  = $exp_dir+"/explorers"
  file_list = Dir.entries($exp_dir).reject{|entry| entry.match(/\._/)}
  if opt["s"]
    host_names    = []
    host_names[0] = opt["s"]
  else
    host_names = file_list
  end
  host_names.each do |host_name|
    $exp_file = file_list.grep(/tar\.gz/).grep(/#{host_name}/)
    $exp_file = $exp_file[0].to_s
    if !$exp_file.match(/[A-z]/)
      puts "Explorer for "+host_name+" does not exist in "+$exp_dir
      exit
    end
  end
  $exp_file = $exp_dir+"/"+$exp_file
end

# Set work directory

if opt["w"]
  $work_dir = opt["w"]
else
  if !$work_dir.match(/[A-z]/)
    $work_dir = "/tmp"
  end
end

if opt["A"]
  report_type = "all"
  config_report(report,report_type)
  exit
end

if opt["I"]
  report_type = "io"
  config_report(report,report_type)
  exit
end

if opt["D"]
  report_type = "disk"
  $do_disks = 1
  config_report(report,report_type)
  exit
end

if opt["O"]
  report_type = "os"
  config_report(report,report_type)
  exit
end

if opt["E"]
  report_type = "eeprom"
  config_report(report,report_type)
  exit
end

if opt["S"]
  report_type = "system"
  config_report(report,report_type)
  exit
end

if opt["Z"]
  report_type = "zones"
  config_report(report,report_type)
  exit
end

if opt["K"]
  report_type = "kernel"
  config_report(report,report_type)
  exit
end

if opt["M"]
  report_type = "memory"
  config_report(report,report_type)
  exit
end

if opt["C"]
  report_type = "cpu"
  config_report(report,report_type)
  exit
end

if opt["H"]
  report_type = "host"
  config_report(report,report_type)
  exit
end

if opt["L"]
  report_type = "ldoms"
  config_report(report,report_type)
  exit
end

if opt["R"]
  report_type = opt["R"]
  if opt["h"]
    report_help(report,report_type)
  else
    if !opt["f"] and !opt["s"]
      puts "Explorer file or home name not specified"
      print_usage(options)
      exit
    end
    config_report(report,report_type)
  end
  exit
end

if opt["h"]
  print_usage(options)
end

#clean_up()
