#!/usr/bin/env ruby

# Name:         parsec (Explorer Parser)
# Version:      2.4.6
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

# Load gems

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

def install_pkg(pkg_name)
  $os_name = %[uname -a].chomp
  if $os_name.match(/SunOS/) and $os_name.match(/5\.11/)
    puts "Information:\tInstalling #{pkg_name}"
    %x[pkg install #{pkg_name}]
  else
    if $os_name.match(/Darwin/)
      if File.exist?("/usr/local/bin/brew")
        puts "Information:\tInstalling #{pkg_name}"
        %x[brew install #{pkg_name}]
      end
    end
  end
  return
end

begin
  require 'iconv'
rescue LoadError
  install_gem("iconv")
end
begin
  require 'getopt/long'
rescue LoadError
  install_gem("getopt")
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
  require 'terminal-table'
rescue LoadError
  install_gem("terminal-table")
end
begin
  require 'unpack'
rescue LoadError
  install_gem("unpack")
end
begin
  require 'enumerate'
rescue LoadError
  install_gem("enumerate")
end
begin
  require 'prawn'
rescue LoadError
  install_gem("prawn")
end
begin
  require 'prawn/table'
rescue LoadError
  install_gem("prawn-table")
end
begin
  require 'fastimage'
rescue LoadError
  install_gem("fastimage")
end
begin
  require 'nokogiri'
rescue LoadError
  install_gem("nokogiri -- --use-system-libraries")
end
begin
  require 'rmagick'
  include Magick
rescue LoadError
  install_pkg("imagemagick")
  install_gem("rmagick")
  require 'rmagick'
  include Magick
end

# Script name

$script = $0

# Valid output formats

$valid_output_formats = [ 'table', 'pdf', 'pipe', 'csv', 'text' ]

# Handle CTRL-C more gracefully

Signal.trap("SIGINT") do
  exit 130
end

# Defaults for PDF

$default_font_size = 12
$section_font_size = 28
$heading_font_size = 18
$table_font_size   = 10

$company_name = "Lateral Blast Pty Ltd"
$author_name  = "Richard Spindler"

# Defaults for output

$output_format  = "pipe"

# Print usage

def print_help()
  switches     = []
  long_switch  = ""
  short_switch = ""
  help_info    = ""
  puts ""
  puts "Usage: "+$script
  puts ""
  file_array  = IO.readlines $0
  option_list = file_array.grep(/\[ "--/)
  option_list.each do |line|
    if !line.match(/file_array/)
      help_info    = line.split(/# /)[1]
      switches     = line.split(/,/)
      long_switch  = switches[0].gsub(/\[/,"").gsub(/\s+/,"")
      short_switch = switches[1].gsub(/\s+/,"")
      if long_switch.gsub(/\s+/,"").length < 7
        puts long_switch+",\t\t"+short_switch+"\t"+help_info
      else
        puts long_switch+",\t"+short_switch+"\t"+help_info
      end
    end
  end
  puts
  return
end

# Get command line arguments
# Print help if given none

if !ARGV[0]
  print_help()
  exit
end

# Try to make sure we have valid long switches

ARGV[0..-1].each do |switch|
  if switch.match(/^-[a-z]=/)
    puts "Invalid command line option: "+switch
    exit
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

# Report types

report             = {}
report["aggr"]     = "Report on aggregate information"
report["all"]      = "Report on everything"
report["coreadm"]  = "Report on coreadm information"
report["cpu"]      = "Report on CPU information"
report["cron"]     = "Report on cron information"
report["crypto"]   = "Report on crypto information"
report["cups"]     = "Report on CUPS information"
report["disk"]     = "Report on disks"
report["dumpadm"]  = "Report on dumpadm information"
report["eeprom"]   = "Report on EEPROM"
report["elfsign"]  = "Report on elfsign information"
report["explorer"] = "Report on Explore information"
report["firmware"] = "Report on Firmware information"
report["fru"]      = "Report on FRU information"
report["fs"]       = "Report on filesystem information"
report["host"]     = "Report on host information"
report["inetadm"]  = "Report on inetadm information"
report["inetd"]    = "Report on inetd information"
report["inetinit"] = "Report on inetinit information"
report["io"]       = "Report on all IO"
report["ipmi"]     = "Report on IPMI information"
report["ldom"]     = "Report on LDom information"
report["link"]     = "Report on link information"
report["locale"]   = "Report on locale information"
report["login"]    = "Report on locale information"
report["lu"]       = "Report on Live Upgrade information"
report["kernel"]   = "Report on kernel information"
report["keyserv"]  = "Report on keyserv information"
report["memory"]   = "Report on Memory information"
report["modinfo"]  = "Report on Kernel Module information"
report["module"]   = "Report on Kernel Module information"
report["mount"]    = "Report on mount information"
report["ndd"]      = "Report on ndd information"
report["network"]  = "Report on network information"
report["ntp"]      = "Report on NTP information"
report["obp"]      = "Report on OBP information"
report["os"]       = "Report on OS information"
report["package"]  = "Report on package information"
report["pam"]      = "Report on PAM information"
report["password"] = "Report on password information"
report["patch"]    = "Report on patch information"
report["power"]    = "Report on power information"
report["security"] = "Report on Security information"
report["sendmail"] = "Report on Sendmail settings"
report["sensors"]  = "Report on Sensor information"
report["serial"]   = "Report on Chassis Serial information"
report["serials"]  = "Report on Component Serial information"
report["services"] = "Report on Services information"
report["slots"]    = "Report on Upgradeable slot information"
report["snmp"]     = "Report on SNMP information"
report["ssh"]      = "Report on SSH information"
report["su"]       = "Report on SU information"
report["suspend"]  = "Report on Suspend information"
report["syslog"]   = "Report on syslog information"
report["system"]   = "Report on system information"
report["swap"]     = "Report on swap information"
report["svm"]      = "Report on Solaris Volume Manager information"
report["tcp"]      = "Report on TCP information"
report["telnet"]   = "Report on Telnet information"
report["udp"]      = "Report on UDP information"
report["vnic"]     = "Report on VNIC information"
report["veritas"]  = "Report on Veritas information"
report["zfs"]      = "Report on ZFS information"
report["zone"]     = "Report on Zone information"
#report[""]=""

# Options

# Process options

begin
  option = Getopt::Long.getopts(
    [ "--prefix",       "-b", Getopt::REQUIRED ],   # Set base/prefix directory
    [ "--customer",     "-C", Getopt::REQUIRED ],   # Set customer name
    [ "--date",         "-T", Getopt::REQUIRED ],   # Set date (used in conjunction with list)
    [ "--dir",          "-d", Getopt::BOOLEAN ],    # Specify directory where explorers are (default is ./explorers)
    [ "--dodisks",      "-D", Getopt::BOOLEAN ],    # Do disks (reports information on all disks)
    [ "--format",       "-f", Getopt::REQUIRED ],   # Output format
    [ "--list",         "-l", Getopt::BOOLEAN ],    # List explorers (also lists dmidecodes and facters if present)
    [ "--masked",       "-m", Getopt::BOOLEAN ],    # Mask hostnames, IPs, MAC addresses etc
    [ "--model",        "-M", Getopt::REQUIRED ],   # Set model (used in conjunction with list)
    [ "--input",        "-i", Getopt::REQUIRED ],   # Input file
    [ "--output",       "-o", Getopt::REQUIRED ],   # Output file
    [ "--pause",        "-p", Getopt::BOOLEAN ],    # Pause between each report when running against all hosts (useful for debugging)
    [ "--report",       "-R", Getopt::REQUIRED ],   # Report type (e.g. all, cpu, memory)
    [ "--server",       "-s", Getopt::REQUIRED ],   # Server to run explorer report for
    [ "--type",         "-t", Getopt::REQUIRED ],   # Type of report (default is explorer)
    [ "--date",         "-T", Getopt::REQUIRED ],   # Set date (used in conjunction with list)
    [ "--temp",         "-w", Getopt::REQUIRED ],   # Work directory
    [ "--usage",        "-u", Getopt::REQUIRED ],   # Display usage information
    [ "--use",          "-U", Getopt::REQUIRED ],   # Override defaults, e.g. use gzip rather than pgiz
    [ "--year",         "-Y", Getopt::REQUIRED ],   # Set year(used in conjunction with list)
    [ "--help",         "-h", Getopt::BOOLEAN ],    # Display help information
    [ "--verbose",      "-v", Getopt::BOOLEAN ],    # Verbose output
    [ "--version",      "-V", Getopt::BOOLEAN ],    # Display version
    [ "--changelog",    "-c", Getopt::BOOLEAN ]     # Print changelog
 )
rescue
  print_help()
  exit
end

# Print Changelog

def print_changelog()
  if File.exist?("changelog")
    changelog = File.readlines("changelog")
    changelog = changelog.reverse
    changelog.each_with_index do |line, index|
      line = line.gsub(/^# /,"")
      if line.match(/^[0-9]/)
        puts line
        puts changelog[index-1].gsub(/^# /,"")
        puts
      end
    end
  end
  return
end

def check_output_format()
  if !$valid_output_formats.grep(/#{$output_format}/)
    puts "Invalid output format"
    exit
  end
end

opt = option

# Print examples

def print_examples(usage)
  match = 0
  if usage.match(/example|report|server|cpu/)
    match = 1
    puts "Run a CPU report against a specific host"
    puts
    puts "$ #{$script} --server=hostname --report=cpu"
    puts
    puts "Run a CPU report against all hosts"
    puts
    puts "$ #{$script} --server=all --report=cpu"
    puts
  end
  if usage.match(/example|report|server|cpu/)
    match = 1
    puts "Run a all reports against a specific host"
    puts
    puts "$ #{$script} --server=hostname --report=all"
    puts
    puts "Run all reports against all hosts"
    puts
    puts "$ #{$script} --server=all --report=all"
    puts
  end
  if usage.match(/example|report|server|cpu|format/)
    match = 1
    puts "Run all reports against a specific host and output a PDF report"
    puts "(will create a file based on the hostname and report in the outputs directory)"
    puts
    puts "$ #{$script} --server=hostname --report=all --format=pdf"
    puts
    puts "Run all reports against a specific host and output PDF a report to a specific file"
    puts
    puts "$ #{$script} --server=hostname --report=all --format=pdf --output=hostename.pdf"
    puts
  end
  if usage.match(/example|report|server|cpu|format/)
    match = 1
    puts "Run a all reports against a specific host and output it in a format that can be piped into another command"
    puts
    puts "$ #{$script} --server=hostname --report=all --format=pipe"
    puts
  end
  if usage.match(/example|report|server|cpu|format/)
    match = 1
    puts "Run a all reports against a specific host and output it in a table format"
    puts
    puts "$ #{$script} --server=hostname --report=all --format=table"
    puts
  end
  if match == 0
    print_help()
  end
  return
end

# Print usage

def print_usage(usage,report)
  case usage
  when /reports/
    puts
    report.each do |type,info|
      if type.length < 7
        puts type+":\t\t"+info
      else
        puts type+":\t"+info
      end
    end
  else
    puts
    print_examples(usage)
  end
  puts
  return
end

# Overide defaults

if option["use"]
  use_flag = option["use"]
  case use_flag
  when /star/
    $tar_bin = %x[which star].chomp
    if !$tar_bin.match(/star/) or $tar_bin.match(/no star/)
      $tar_bin = %x[which tar].chomp
    end
  when /tar/
    $tar_bin = %x[which tar].chomp
  when /pigz/
    $gzip_bin = %x[which pigz].chomp
    if !$gzip_bin.match(/pigz/) or $gzip_bin.match(/no pigz/)
      $gzip_bin = %x[which gzip].chomp
    end
  when /gzip/
    $gzip_bin = %x[which gzip].chomp
  end
end

# Print help

if option["help"]
  print_help()
  exit
end

if option["usage"]
  usage = option["usage"]
  print_usage(usage,report)
  exit
end

# Enable verbose mode

if option["verbose"]
  $verbose_mode = 1
  puts "Operating in verbose mode"
end

# get server name

if option["server"]
  host_name = option["server"].downcase
  if !option["report"]
    option["report"] = "all"
    if $verbose_mode == 1
      puts "reporting on all elements of "+host_name
    end
  end
end

# Get model type

if option["model"]
  search_model = option["model"]
else
  search_model = ""
end

# Get date string

if option["date"]
  search_date = option["date"]
  if !search_date.match(/latest|last|earliest|first/)
    begin
      search_date = Date.parse(search_date).to_s
    rescue
      puts "Invalid date"
      exit
    end
  end
else
  if option["list"]
    search_date = ""
  else
    search_date = "latest"
  end
end

# Get year string

if option["year"]
  search_year = option["year"]
  if search_year.length == 2
    search_year = "20"+search_year
  end
  if search_year.match(/[a-z,A-Z]/)
    puts "Invalid year"
    exit
  end
else
  search_year = ""
end

# Check local config

if !option["help"] and !option["version"]
  check_local_config()
end

if option["prefix"]
  $base_dir = option["prefix"]
else
  $base_dir = Dir.pwd
end

# Print version

if option["version"]
  print_version()
  exit
end

# Print changelog

if option["changelog"]
  print_changelog()
  exit
end

# Set format of report

if option["format"]
  $output_format = option["format"].downcase
  $output_format = $output_format.gsub(/text/,"pipe")
  check_output_format()
else
  $output_format = "pipe"
  if $verbose_mode == 1
    puts "Setting output type to "+$output_format
  end
end

# Pause mode

if option["pause"]
  pause_mode = 1
else
  pause_mode = 0
end

# Mask data

if option["masked"]
  $masked = 1
  if $verbose_mode == 1
    puts "Masking output"
  end
end

# Set explorer directory

if option["dir"]
  $exp_dir = opt["dir"]
else
  if !$exp_dir.match(/[A-z]/)
    $exp_dir = Dir.pwd+"/explorers"
  end
end

# Set type

if option["type"]
  input_type = option["type"]
else
  input_type = "explorer"
end

# Set output file

if option["output"]
  $output_file = option["output"]
  $output_dir  = File.dirname($output_file)
  if !File.directory?($output_dir) and !File.symlink?($output_dir)
    Dir.mkdir($output_dir)
  end
  if $verbose_mode == 1 and !host_name.match(/^all$/)
    puts "Setting output file to: "+$output_file
  end
  if File.exist?($output_file)
    File.delete($output_file)
    FileUtils.touch($output_file)
  else
    FileUtils.touch($output_file)
  end
else
  $output_file = ""
  $output_dir  = $base_dir+"/output"
  if !File.directory?($output_dir) and !File.symlink?($output_dir)
    Dir.mkdir($output_dir)
  end
  if $output_format.match(/pdf/)
    if !host_name.match(/^all$/)
      $output_file = $output_dir+"/"+host_name+".txt"
    end
  end
end

# List explorers

if option["list"]
  if input_type.match(/all|explorer/)
    if !host_name
      host_name = ""
    end
    list_explorers(search_model,search_date,search_year,host_name)
  end
  if input_type.match(/all|facter/)
    list_facters()
  end
  if input_type.match(/all|dmidecode/)
    list_dmidecodes()
  end
  exit
end

# Report on all disk information

if option["dodisks"]
  $do_disks = 1
  if $verbose_mode == 1
    puts "Enabling full disk reporting"
  end
end

# Handle filename and hostname options

if option["input"]
  $exp_file = option["input"]
  if !File.exist?($exp_file) and !File.symlink?($exp_file)
    puts
    puts "Input file: "+$exp_file+" does not exist"
    exit
  end
  host_name  = get_hostname_from_explorer_File()
  exp_data[host_name]["file"] = $exp_file
  host_names = []
  host_names.push(host_name)
else
  if !option["server"]
    if !option["help"]
      puts
      puts "Input file or hostname not specified"
    end
    print_help()
    exit
  end
  $exp_dir    = $base_dir.chomp()
  $exp_dir    = $exp_dir+"/explorers"
  search_name = option["server"]
  file_list   = get_explorer_file_list(search_model,search_date,search_year,search_name)
end

# Set work directory

if option["temp"]
  $work_dir = option["temp"]
else
  if !$work_dir.match(/[A-z]/)
    $work_dir = "/tmp"
  end
end

# Get report type

if option["report"]
  $report_type = option["report"]
  $report_type = $report_type.gsub(/cpus/,"cpu").gsub(/zone$/,"zones").gsub(/disks/,"disk").gsub(/sds/,"svm")
  check_valid_report_type($report_type)
  if !option["input"] and !option["server"]
    puts "Input file or home name not specified"
    print_help()
    exit
  end
end

# Get customer name

if option["customer"]
  if $masked == "1"
    customer_name = "Masked"
  else
    customer_name = option["customer"]
  end
else
  customer_name = ""
end

# Handle explorer output

if input_type.match(/explorer/)
 handle_explorer(report,file_list,search_model,search_date,search_year,search_name)
end
