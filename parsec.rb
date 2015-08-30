#!/usr/bin/env ruby

# Name:         parsec (Explorer Parser)
# Version:      0.7.0
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
require 'prawn'
require 'prawn/table'
require 'pathname'
require 'etc'
require 'fastimage'
require 'unpack'
require 'enumerator'
require 'nokogiri'
require 'rmagick'

include Magick

$default_font_size = 12
$section_font_size = 28
$heading_font_size = 18
$table_font_size   = 10

# Detauks for PDF

$company_name = "Lateral Blast Pty Ltd"
$author_name  = "Richard Spindler"

$output_mode = "text"

options   = "abcdefhlmvABCDEFHIKLMOPSTVZd:i:s:w:R:o:p:"
$pigz_bin = %x[which pigz].chomp

# Set up some script related variables

$methods_dir     = ""
$information_dir = ""
$firmware_dir    = ""

script_dir = File.basename($0)
if !script_dir.match(/\//)
  script_dir = Dir.pwd
end
$image_dir    = script_dir+"/images"
$handbook_dir = script_dir+"/handbook"
$fact_dir     = script_dir+"/facters"
$decode_dir   = script_dir+"/dmidecode"

[ "methods", "information", "firmware", "handbook" ].each do |test_dir|
  required_dir = eval("$#{test_dir}_dir")
  if !required_dir.match(/[A-z]/)
    required_dir = script_dir+"/"+test_dir
    if !File.directory?(required_dir) and !File.symlink?(required_dir)
      puts "Cannot locate "+test_dir+" directory ("+required_dir+")"
      puts "Creating "+test_dir+" directory ("+required_dir+")"
      Dir.mkdir(required_dir)
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

# Get script name

def get_code_name()
  code_name = $0
  code_name = Pathname.new(code_name)
  code_name = code_name.basename.to_s
  code_name = code_name.gsub(".rb","")
  return code_name
end

$script_name = get_code_name()

# Get version of script

def get_code_ver()
  code_ver = IO.readlines($0)
  code_ver = code_ver.grep(/^# Version/)
  code_ver = code_ver[0].to_s.split(":")
  code_ver = code_ver[1].to_s.gsub(" ","")
  return code_ver
end

# Check local config

def check_local_config()
  if !$pigz_bin.match(/pigz/)
    puts "Parallel GZip (pigz) not installed"
    os_name = %x[uname -v]
    if os_name.match(/Darwin/)
      brew_bin = %x[which brew]
      if brew_bin.match(/brew/)
        %x[brew install pigz]
      else
        exit
      end
    else
      exit
    end
  end
  return
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
  puts "-i: Specify Explorer file to process"
  puts "-s: Specify System to process"
  puts "    (Filename will be determined if it exists)"
  puts "-m: Mask data (hostnames etc)"
  puts "-d: Set Explorer directory"
  puts "-l: List explorers, and facts for either puppet or ansible"
  puts "-B: Report based on DMI decode"
  puts "-F: Report based on Puppet Facter output"
  puts "-A: Report based on Ansible Fact output"
  puts "-a: Process all explorers"
  puts "-P: Output in PDF mode"
  puts "-T: Output in text mode (default)"
  puts "-O: Output to file (in output directory)"
  puts
  puts "Reporting:"
  puts
  puts "-R: Report/Print configuration information for a specific component:"
  puts
  puts "    all:        All information"
  puts "    obp:        Open Boot Prom information"
  puts "    host:       Host information"
  puts "    eeprom:     EEPROM information"
  puts "    os:         Operating Sytem information"
  puts "    coreadm:    Coreadm information"
  puts "    dumpadm:    Dupadm information"
  puts "    explorer:   Explorer information"
  puts "    cpu:        CPU information"
  puts "    memory:     Memory information"
  puts "    io:         IO Information (Controllers, HBAs etc)"
  puts "    disk:       Disk information"
  puts "    kernel:     Kernel information"
  puts "    zones:      Zone information"
  puts "    security:   All security information"
  puts "    password:   Password information"
  puts "    system:     System information"
  puts "    login:      Login information"
  puts "    sendmail:   Sendmail information"
  puts "    inetinit:   Inetinit information"
  puts "    su:         Su information"
  puts "    inetd:      Inetd information"
  puts "    cron:       Cron information"
  puts "    keyserv:    keyserv information"
  puts "    telnet:     Telnet information"
  puts "    power:      Power information"
  puts "    suspend:    Suspend information"
  puts "    ssh:        SSH information"
  puts "    fs:         Filesystem information"
  puts "    services:   Services information"
  puts "    lu:         LiveUpgrade information"
  puts "    locale:     Locale information"
  puts "    modinfo:    Module information"
  puts "    package:    Package information"
  puts "    patch:      Patch information"
  puts "    tcp:        TCP information"
  puts "    udp:        UDP information"
  puts "    ldom:       LDom information"
  puts "    fru:        FRU information"
  puts
  puts "Example (Display CPUs):"
  puts
  puts code_name+" -s hostanme -R cpu"
  puts
  puts "Explorer shortcuts:"
  puts
  puts "-Z: Print all configuration information (default)"
  puts "-E: Print EEPROM configuration information"
  puts "-I: Print IO configuration information"
  puts "-H: Print Host configuration information"
  puts "-L: Print LDom configuration information"
  puts "-C: Print CPU configuration information"
  puts "-S: Print OS configuration information"
  puts "-Y: Print System configuration information"
  puts
  exit
end

begin
  opt = Getopt::Std.getopts(options)
rescue
  print_usage(options)
end

# Check local config

if !opt['h'] and !opt["V"]
  check_local_config()
end

# Output mode

if opt["T"]
  if opt["R"] or opt["A"] or opt["F"] or opt["B"] or opt["Z"]
    $output_mode = "text"
  else
    puts "Report type not specified"
    puts "Must use -R, -A, -B, -Z, or -F"
    exit
  end
else
  if opt["P"] or opt["o"] or opt["O"]
    if opt["R"] or opt["A"] or opt["F"] or opt["B"] or opt["Z"]
      $output_mode = "file"
    else
      puts "Report type not specified"
      puts "Must use -R, -A, -B, -Z, or -F"
      exit
    end
  else
    $output_mode = "text"
  end
end

# Get hostname

if opt["s"]
  host_name = opt["s"]
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
  list_facters()
  #list_dmidecodes()
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

if opt["i"]
  $exp_file = opt["i"]
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
  if !opt["A"] and !opt["F"] and !opt["B"]
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
end

if opt["o"]
  $output_file = opt["o"]
else
  $output_file = "output/"+host_name+".txt"
  output_dir = File.dirname($output_file)
  if !File.directory?(output_dir)
    Dir.mkdir(output_dir)
  end
end

if opt["P"] or opt["O"]
  if $output_file.match(/\.pdf$|\.PDF$/)
    $output_file = $output_file.gsub(/\.pdf$|\.PDF$/,"")
  end
  if !$output_file.match(/\.txt$/)
    $output_file = $output_file+".txt"
  end
  output_dir = File.dirname($output_file)
  if !File.directory?(output_dir)
    Dir.mkdir(output_dir)
  end
  if opt["P"]
    if opt["R"] or opt["Z"]
      document_title = "Explorer: "+host_name
    end
    if opt["A"]
      document_title = "Ansible Facts: "+host_name
    end
    if opt["F"]
      document_title = "Puppet Facts: "+host_name
    end
    if opt["B"]
      document_title = "DMI decode: "+host_name
    end
    customer_name  = ""
    output_pdf     = "output/"+host_name+".pdf"
  end
end

if opt["o"] or opt["P"] or opt["O"]
  if File.exist?($output_file)
    File.delete($output_file)
    FileUtils.touch($output_file)
  else
    FileUtils.touch($output_file)
  end
end

# Set work directory

if opt["w"]
  $work_dir = opt["w"]
else
  if !$work_dir.match(/[A-z]/)
    $work_dir = "/tmp"
  end
end

if opt["Z"]
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

if opt["S"]
  report_type = "os"
  config_report(report,report_type)
  exit
end

if opt["E"]
  report_type = "eeprom"
  config_report(report,report_type)
  exit
end

if opt["Y"]
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
    if !opt["i"] and !opt["s"]
      puts "Explorer file or home name not specified"
      print_usage(options)
      exit
    end
    config_report(report,report_type)
  end
end

if opt["h"]
  print_usage(options)
end

# Handle Facter / dmidecode

if opt["F"] or opt["A"] or opt["B"]
  if opt["s"]
    host_name = opt["s"]
    file_name = ""
  end
  if opt["i"]
    file_name = opt["i"]
    host_name = ""
  end
  if opt["F"]
    process_puppet_facter(host_name,file_name)
  end
  if opt["A"]
    process_ansible_facter(host_name,file_name)
  end
  if opt["B"]
    process_dmidecode(host_name,file_name)
  end
end

# Handle output of PDF

if opt["P"]
  pdf = Prawn::Document.new
  output_pdf = $output_file.gsub(/\.txt$/,".pdf")
  generate_pdf(pdf,document_title,output_pdf,customer_name)
end

#clean_up()
