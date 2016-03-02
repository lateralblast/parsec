#!/usr/bin/env ruby

# Name:         parsec (Explorer Parser)
# Version:      1.8.2
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
require 'getopt/long'
require 'pathname'
require 'hex_string'
require 'terminal-table'
require 'pathname'
require 'etc'
require 'unpack'
require 'enumerator'

begin
  require 'prawn'
  require 'prawn/table'
  require 'fastimage'
  require 'nokogiri'
  require 'rmagick'
  include Magick
rescue LoadError
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

# Check for pigz to accelerate decompression

$gzip_bin = %x[which pigz].chomp

# Set up some script related variables

$methods_dir     = ""
$information_dir = ""
$firmware_dir    = ""

script_dir = File.basename($0)
if !script_dir.match(/\//)
  script_dir = Dir.pwd
end

$data_dir     = script_dir+"/data"
$handbook_dir = $data_dir+"/handbook"
$fact_dir     = $data_dir+"/facters"
$decode_dir   = $data_dir+"/dmidecode"
$info_dir     = $data_dir+"/information"
$images_dir   = $data_dir+"/images"

[ $data_dir, $images_dir, $handbook_dir, $fact_dir, $decode_dir, $info_dir ].each do |test_dir|
  if !File.directory?(test_dir) and !File.symlink?(test_dir)
    puts "Cannot locate "+test_dir+" directory ("+test_dir+")"
    puts "Creating "+test_dir+" directory ("+test_dir+")"
    Dir.mkdir(test_dir)
  end
end

$pci_ids_url  = "http://pci-ids.ucw.cz/v2.2/pci.ids"
$pci_ids_file = script_dir+"/information/pci.ids"

$pci_ids = []

if File.exist?($pci_ids_file)
  $pci_ids = File.readlines($pci_ids_file)
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
report["tcp"]      = "Report on TCP information"
report["telnet"]   = "Report on Telnet information"
report["udp"]      = "Report on UDP information"
report["vnic"]     = "Report on VNIC information"
report["veritas"]  = "Report on Veritas information"
report["zfs"]      = "Report on ZFS information"
report["zone"]     = "Report on Zone information"
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

# Options

# Process options

begin
  option = Getopt::Long.getopts(
    [ "--prefix",       "-b", Getopt::REQUIRED ],   # Set base/prefix directory
    [ "--customer",     "-C", Getopt::REQUIRED ],   # Set customer name 
    [ "--dir",          "-d", Getopt::BOOLEAN ],    # Specify directory where explorers are (default is ./explorers)
    [ "--dodisks",      "-D", Getopt::BOOLEAN ],    # Do disks (reports information on all disks)
    [ "--format",       "-f", Getopt::REQUIRED ],   # Output format
    [ "--list",         "-l", Getopt::BOOLEAN ],    # List explorers (also lists dmidecodes and facters if present)
    [ "--masked",       "-m", Getopt::BOOLEAN ],    # Mask hostnames, IPs, MAC addresses etc
    [ "--model",        "-o", Getopt::REQUIRED ],   # Set model (used in conjunction with list)
    [ "--output",       "-o", Getopt::REQUIRED ],   # Output file
    [ "--pause",        "-p", Getopt::BOOLEAN ],    # Pause between each report when running against all hosts (useful for debugging)
    [ "--report",       "-R", Getopt::REQUIRED ],   # Report type (e.g. all, cpu, memory)
    [ "--server",       "-s", Getopt::REQUIRED ],   # Server to run explorer report for
    [ "--type",         "-t", Getopt::REQUIRED ],   # Type of report (default is explorer)
    [ "--temp",         "-w", Getopt::REQUIRED ],   # Work directory
    [ "--usage",        "-u", Getopt::REQUIRED ],   # Display usage information
    [ "--use",          "-U", Getopt::REQUIRED ],   # Override defaults, e.g. use gzip rather than pgiz
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

# Check local config

def check_local_config()
  os_name = %x[uname -v]
  if !os_name.match(/SunOS/)
    $tar_bin = %x[which star].chomp
    if !$tar_bin.match(/star/) or $tar_bin.match(/no star/)
      if $verbose_mode == 1
        puts "S tar not installed"
      end
      if os_name.match(/Darwin/)
        if brew_bin.match(/brew/)
          puts "Installing S tar"
          %x[brew install star]
        else
          puts "Cannot find S tar"
          puts "S tar is required"
          exit
        end
      else
        if !$tar_bin.match(/star/)
          puts "Cannot find S tar"
          puts "S tar is required"
        end
      end
    end
  else
    $tar_bin = %x[which star].chomp
    if !$tar_bin.match(/star/) or $tar_bin.match(/no star/)
      if $verbose_mode == 1
        puts "Using gzip"
      end
      $tar_bin = "/usr/bin/tar"
    end
  end
  if !$gzip_bin.match(/pigz/)
    if $verbose_mode == 1
      puts "Parallel GZip (pigz) not installed"
    end
    if os_name.match(/Darwin/)
      brew_bin = %x[which brew]
      if brew_bin.match(/brew/) and !brew_bin.match(/no brew/)
        puts "Installing Parallel GZip"
        %x[brew install pigz]
      else
        $gzip_bin = %x[which gzip].chomp
        if !$gzip_bin.match(/gzip/) or $gzip_bin.match(/no gzip/)
          puts "Cannot find gzip"
          exit
        else
          if $verbose_mode == 1
            puts "Using gzip"
          end
        end
      end
    else
      $gzip_bin = %x[which gzip].chomp
      if !$gzip_bin.match(/gzip/) or $gzip_bin.match(/no gzip/)
        puts "Cannot find gzip"
        exit
      else
        if $verbose_mode == 1
          puts "Using gzip"
        end
      end
    end
  end
  return
end

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

# List explorers

if option["list"]
  if input_type.match(/all|explorer/)
    list_explorers(search_model)
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
else
  if !option["server"] 
    if !option["help"]
      puts
      puts "Input file or hostname not specified"
    end
    print_help()
    exit
  end
  $exp_dir  = $base_dir.chomp()
  $exp_dir  = $exp_dir+"/explorers"
  file_list = Dir.entries($exp_dir).reject{|entry| entry.match(/\._/)}
  if option["server"]
    if option["server"].match(/^all$/)
      host_names = []
      file_list.each do |file_name|
        if file_name.match(/\-/) and file_name.match(/tgz|tar/) and file_name.match(/explorer/)
          temp_name = file_name.split(/\./)[2].split(/\-/)[0..-2].join("-")
          host_names.push(temp_name)
        end
      end
      host_names = host_names.uniq
    else
      host_names    = []
      host_names[0] = option["server"]
    end
  else
    host_names = file_list
  end
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

# Set output file

if option["output"]
  $output_file = option["output"]
  $output_dir  = File.dirname($output_file)
  if !File.directory?($output_dir)
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
  $output_dir = $base_dir+"/output"
  if $output_format.match(/pdf/)
    if !host_name.match(/^all$/)
      $output_file = $output_dir+"/"+host_name+".txt"
    end
  end
end

# Handle explorer output

if input_type.match(/explorer/)
  host_names.each do |temp_name|
    if host_name.match(/^all$/) and $output_format.match(/pdf/)
      $output_file = $output_dir+"/"+temp_name+"-"+$report_type+".txt"
    end
    if $verbose_mode == 1 and !$output_format.match(/pdf/)
      puts "Processing explorer ("+$report_type+") report for "+temp_name
    end
    $exp_file = file_list.grep(/tar\.gz/).grep(/#{temp_name}/)
    if $exp_file.to_s.match(/\n/)
      $exp_file = $exp_file.split(/\n/)
    end
    $exp_file = $exp_file[0].to_s.chomp
    $exp_file = $exp_dir+"/"+$exp_file
    if !$exp_file.match(/#{temp_name}/)
      puts "Explorer for "+temp_name+" does not exist in "+$exp_dir
      exit
    end
    config_report(report,temp_name)
    if host_name.match(/^all$/) and pause_mode == 1
      print "continue (y/n)? "
      STDOUT.flush()
      exit if 'n' == STDIN.gets.chomp
    end
    if $output_format.match(/pdf/)
      pdf = Prawn::Document.new
      if host_name.match(/^all$/)
        output_pdf = $output_dir+"/"+temp_name+".pdf"
      else
        output_pdf = $output_file.gsub(/\.txt$/,".pdf")
      end
      if $verbose_mode == 1
        puts "Input file:  "+$output_file
        puts "Output file: "+output_pdf
      end
      if $masked == 1
        document_title = "Explorer: masked"
      else
        document_title = "Explorer: "+temp_name
      end
      if !customer_name.match(/masked/) and host_name.match(/^all$/)
        customer_name = get_customer_name()
      end
      generate_pdf(pdf,document_title,output_pdf,customer_name)
    end
  end
end
