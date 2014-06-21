#!/usr/bin/env ruby

# Name:         parsec (Explorer Parser)
# Version:      0.1.3
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
require 'versionomy'

options="abcdehmvACDEHIKMOSVZf:s:w:R:o:"

# Load methods

if Dir.exists?("./methods")
  file_list=Dir.entries("./methods")
  for file in file_list
    if file =~/rb$/
      require "./methods/#{file}"
    end
  end
end

# Set global variables

$work_dir=""
$explorer_file=""
$explorer_dir=""
$verbose=0
$base_dir=""
$do_disks=0
$host_info={}
$explorer_file_list=[]
$masked=0

# Report types

report={}
report["io"]="Report on all IO"
report["emulex"]="Report on Emulex FC devices"
report["qlogic"]="Report on Qlogic FC devices"
report["disk"]="Report on disks"
report["eeprom"]="Report on EEPROM"
report["security"]="Report on Security settings"
report["password"]="Report on Password settings"
report["host"]="Report on Host information"
report["memory"]="Report on Memory information"
report["cpu"]="Report on CPU information"
#report[""]=""

# Get no of ports

def get_hba_port_no(io_name)
  no_ports="1"
  if io_name.match(/0\-S$|0$|FCX\-|10F$/)
      no_ports="1"
  else
    if io_name.march(/1\-S$|1$|0DC\-S$|2\-S$|2$|FCX2\-|2F$/)
      no_ports="2"
    end
  end
  return no_ports
end

# Get code name and version

def get_code_name
  code_name=$0
  code_name=Pathname.new(code_name)
  code_name=code_name.basename.to_s
  code_name=code_name.gsub(".rb","")
  return code_name
end

def get_code_version
  code_version=IO.readlines($0)
  code_version=code_version.grep(/^# Version/)
  code_version=code_version[0].to_s.split(":")
  code_version=code_version[1].to_s.gsub(" ","")
  return code_version
end

# Print usage

def print_usage(options)
  code_name=get_code_name()
  code_version=get_code_version()
  puts
  puts code_name+" v. "+code_version
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
  puts "-C: Print CPU configuration information"
  puts "-R: Print configuration information for a specific component"
  puts "-m: Mask data (hostnames etc)"
  puts
  puts "Example (Display CPUs):"
  puts
  puts code_name+" -s hostanme -R cpu"
  puts
  exit
end

# Open Disk firmware file
# file generated from output of goofball
# goofball.rb -d all -c

def info_file_to_array(file_name)
  info_file=$base_dir+"/information/"+file_name
  if File.exists?(info_file)
    file_array=IO.readlines info_file
  end
  return file_array
end

# Get available disk firmware version

def get_avail_disk_firmware(disk_model)
  file_name="disk_firmware"
  fw_info=info_file_to_array(file_name)
  return fw_info
end

# Get available Emulex HBA firmware version

def get_avail_emulex_firmware()
  file_name="emulex_firmware"
  fw_info=info_file_to_array(file_name)
  return fw_info
end

# Get available Qlogic HBA firmware version

def get_avail_qlogic_firmware()
  file_name="qlogic_firmware"
  fw_info=info_file_to_array(file_name)
  return fw_info
end


# Process available disk firmware version

def process_avail_disk_firmware(table,disk_model,disk_firmware)
  fw_info=get_avail_disk_firmware(disk_model)
  if fw_info
    fw_info.each do |fw_line|
      if fw_line.match(/^#{disk_model}/)
        fw_line=fw_line.split(/,/)
        avail_firmware=fw_line[1]
        avail_firmware=avail_firmware.split(/\(/)[1].gsub(/\)/,'')
        readme_url=fw_line[2]
        patch_url=fw_line[3]
        if avail_firmware > disk_firmware
          table=handle_output("row","Available Firmware",avail_firmware,table)
          table=handle_output("row","Firmware README",readme_url,table)
          table=handle_output("row","Firmware Patch",patch_url,table)
        end
      end
    end
  end
  return table
end

# Process available Emulex HBA firmware version

def process_avail_qlogic_firmware(table,qlogic_model,qlogic_firmware)
  table=handle_output("row","Installed Firmware",qlogic_firmware,table)
  fw_info=get_avail_qlogic_firmware()
  uc_qlogic_model=qlogic_model.upcase
  if fw_info
    fw_info.each do |fw_line|
      if fw_line.match(/^#{uc_qlogic_model}/)
        fw_line=fw_line.split(/,/)
        avail_firmware=fw_line[1]
        readme_url=fw_line[2]
        current_version=Versionomy.parse(qlogic_firmware)
        avail_version=Versionomy.parse(avail_firmware)
        if avail_version > current_version
          avail_firmware=avail_firmware+" (Newer)"
          table=handle_output("row","Available Firmware",avail_firmware,table)
          table=handle_output("row","Firmware Download",readme_url,table)
        end
      end
    end
  end
  return table
end

# Process available Qlogic GBA firmware version

def process_avail_emulex_firmware(table,emulex_model,emulex_firmware)
  table=handle_output("row","Installed Firmware",emulex_firmware,table)
  fw_info=get_avail_emulex_firmware()
  emulex_model=emulex_model.gsub(/-S/,'')
  uc_emulex_model=emulex_model.upcase
  emulex_firmware=emulex_firmware.split(/ /)[0]
  if fw_info
    fw_info.each do |fw_line|
      if fw_line.match(/^#{uc_emulex_model}/)
        fw_line=fw_line.split(/,/)
        avail_firmware=fw_line[1].split(/ /)[3]
        readme_url=fw_line[2]
        current_version=Versionomy.parse(emulex_firmware)
        avail_version=Versionomy.parse(avail_firmware)
        if avail_version > current_version
          avail_firmware=avail_firmware+" (Newer)"
          table=handle_output("row","Available Firmware",avail_firmware,table)
          table=handle_output("row","Firmware Download",readme_url,table)
        end
      end
    end
  end
  return table
end

# Get file date

def get_extracted_file_date(file_name)
  explorer_name=File.basename($explorer_file,".tar.gz")
  extracted_file=$work_dir+"/"+explorer_name+file_name
  if !File.exists?(extracted_file)
    extract_explorer_file(extracted_file)
  end
  file_date=File.mtime(extracted_file)
  return(file_date)
end

# Extract a file from the the explorer .tar.gz

def extract_explorer_file(file_to_extract)
  if File.exists?($explorer_file)
    command="cd #{$work_dir} ; tar -xpzf #{$explorer_file} #{file_to_extract} > /dev/null 2>&1"
    if !$explorer_file_list[1]
      $explorer_file_list=`tar -tzf #{$explorer_file}`
      $explorer_file_list=$explorer_file_list.split(/\n/)
    end
    if $explorer_file_list.include?(file_to_extract)
      if $verbose == 1
        puts "Executing: "+command
      end
      system(command)
    end
  end
end

# Put the requested file from the explorer into an array.
# Each line is an array element.
# Checks to see if file has already been extracted

def explorer_file_to_array(file_name)
  file_array=[]
  explorer_name=File.basename($explorer_file,".tar.gz")
  extracted_file=$work_dir+"/"+explorer_name+file_name
  if !File.exists?(extracted_file)
    file_to_extract=explorer_name+file_name
    extract_explorer_file(file_to_extract)
  end
  if File.exists?(extracted_file)
    file_array=IO.readlines extracted_file
  else
    if $verbose == 1
      puts "File #{file_name} does not exist"
    end
  end
  return file_array
end

# Generic output routine which formats text appropriately.

def handle_output(type,title,row,table)
  if type.match(/title/)
    puts
    if row.to_s.match(/[A-z]/)
      table=Terminal::Table.new :title => title, :headings => row
    else
      table=Terminal::Table.new :title => title, :headings => ['Item', 'Value']
    end
  end
  if type.match(/end/)
    puts table
  end
  if type.match(/line/)
    table.add_separator
  end
  if type.match(/row/)
    if title.match(/[A-z]/)
      row=[title,row]
    end
    if row.length == 2
      item=row[0]
      value=row[1]
      $host_info[item]=value
    end
    table.add_row(row)
  end
  return table
end

# Get FC device information and put it in an array
# Information is in a multi line form so split it
# on the HBA Port WWN string so all the information
# about a controller is in an array element

def get_fc_info()
  os_version=get_os_version()
  if os_version.match(/10|11/)
    file_name="/sysconfig/fcinfo.out"
    file_array=explorer_file_to_array(file_name)
    fc_info=file_array.join.split("HBA Port WWN: ")
  else
    file_name="/disks/luxadm_fcode_download_-p.out"
    file_array=explorer_file_to_array(file_name)
    fc_info=file_array.join.split("Opening Device: ")
  end
  return fc_info
end

# Get HBA fcode version

def get_hba_fcode(io_path)
  file_name="/disks/luxadm_fcode_download_-p.out"
  file_array=explorer_file_to_array(file_name)
  fc_info=file_array.join.split("Opening Device: ")
  fc_info=fc_info.grep(/#{io_path}\/fp/)
  fc_info=fc_info.join.split(/\n/)[1]
  fcode_version=fc_info.split(/:/)[1].gsub(/\s+/,'')
  return fcode_version
end

# Get controller information

def get_controller_info(io_path,controller_no)
  # Handle FC devices
  os_version=get_os_version()
  if io_path.match(/emlxs/)
    fc_info=get_fc_info()
    if os_version.match(/10|11/)
      controller_path="/dev/cfg/"+controller_no
      fc_info=fc_info.grep(/#{controller_path}/)
    else
      fc_info=fc_info.grep(/#{io_path}\/fp/)
    end
    fc_info=fc_info.join.split(/\n/)
    return fc_info
  end
end

# Get HBA Boot Code

def get_hba_bcode(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  bcode_version=controller_info.grep(/Boot/)[0].split(/Boot:/)[1].split(/ /)[0]
  return bcode_version
end

# Get HBA Current Speed

def get_hba_current_speed(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_current_speed=controller_info.grep(/Current Speed/)[0].split(/: /)[1]
  return hba_current_speed
end

# Get HBA Supported Speeds

def get_hba_supported_speeds(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_supported_speeds=controller_info.grep(/Supported Speeds/)[0].split(/: /)[1]
  return hba_supported_speeds
end

# Get HBA Firmware version

def get_hba_firmware_version(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_firmware_version=controller_info.grep(/Firmware Version/)[0].split(/: /)[1]
  return hba_firmware_version
end

# Get HBA Driver version

def get_hba_driver_version(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_driver_version=controller_info.grep(/Driver Version/)[0].split(/: /)[1]
  return hba_driver_version
end

# Get HBA Driver name

def get_hba_driver_name(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_driver_name=controller_info.grep(/Driver Name/)[0].split(/: /)[1]
  return hba_driver_name
end

# Get HBA State

def get_hba_state(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_state=controller_info.grep(/State/)[0].split(/: /)[1]
  return hba_state
end

# Get HBA Type

def get_hba_type(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_type=controller_info.grep(/Type/)[0].split(/: /)[1]
  return hba_type
end

# Get HBA Type

def get_hba_wwn(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_wwn=controller_info.grep(/Node WWN/)[0].split(/: /)[1]
  return hba_wwn
end

# Get HBA Serial

def get_hba_serial(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_serial=controller_info.grep(/Serial Number/)[0].split(/: /)[1]
  return hba_serial
end

# Get HBA Link Failures

def get_hba_link_failures(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_link_failures=controller_info.grep(/Link Failure Count/)[0].split(/: /)[1]
  return hba_link_failures
end

# Get HBA Sync Losses

def get_hba_sync_losses(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_sync_losses=controller_info.grep(/Loss of Sync Count/)[0].split(/: /)[1]
  return hba_sync_losses
end

# Get HBA Signal Loss

def get_hba_signal_losses(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_signal_losses=controller_info.grep(/Loss of Signal Count/)[0].split(/: /)[1]
  return hba_signal_losses
end

# Get HBA Protocol Errors

def get_hba_protocol_errors(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_protocol_errors=controller_info.grep(/Primitive Seq Protocol Error Count/)[0].split(/: /)[1]
  return hba_protocol_errors
end

# Get HBA Invalid Tx Words

def get_hba_invalid_tx(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_invalid_tx=controller_info.grep(/Invalid Tx Word Count/)[0].split(/: /)[1]
  return hba_invalid_tx
end

# Get HBA Invalid CRC

def get_hba_invalid_crc(io_path,controller_no)
  if !controller_no.match(/^c/)
    controller_no=get_controller_no(io_path)
  end
  controller_info=get_controller_info(io_path,controller_no)
  hba_invalid_crc=controller_info.grep(/Invalid CRC Count/)[0].split(/: /)[1]
  return hba_invalid_crc
end

# Processes fcinfo into an array

def process_controller_info(table,io_name,io_path,controller_no)
  controller_info=get_controller_info(io_path,controller_no)
  os_version=get_os_version()
  # Handle FC devices
  no_ports=""
  fc_speed=""
  pci_string=""
  if io_path.match(/emlxs|qlc/)
    if os_version.match(/10|11/)
      hba_serial=get_hba_serial(io_path,controller_no)
      if $masked == 0
        table=handle_output("row","Serial",hba_serial,table)
      else
        table=handle_output("row","Serial","XXXXXXXX",table)
      end
      hba_wwn=get_hba_wwn(io_path,controller_no)
      if $masked == 0
        table=handle_output("row","Node WWN",hba_wwn,table)
      else
        table=handle_output("row","Node WWN","XXXXXXXX",table)
      end
      hba_state=get_hba_state(io_path,controller_no)
      table=handle_output("row","State",hba_state,table)
      hba_type=get_hba_type(io_path,controller_no)
      table=handle_output("row","Type",hba_type,table)
      bcode_version=get_hba_bcode(io_path,controller_no)
      table=handle_output("row","BCode",bcode_version,table)
      hba_current_speed=get_hba_current_speed(io_path,controller_no)
      table=handle_output("row","Current Speed",hba_current_speed,table)
      hba_supported_speeds=get_hba_supported_speeds(io_path,controller_no)
      table=handle_output("row","Supported Speeds",hba_supported_speeds,table)
      hba_firmware_version=get_hba_firmware_version(io_path,controller_no)
      table=handle_output("row","Firmware Version",hba_firmware_version,table)
      hba_driver_name=get_hba_driver_name(io_path,controller_no)
      table=handle_output("row","Driver Name",hba_driver_name,table)
      hba_driver_version=get_hba_driver_version(io_path,controller_no)
      table=handle_output("row","Driver Version",hba_driver_version,table)
      hba_link_failures=get_hba_link_failures(io_path,controller_no)
      table=handle_output("row","Link Failures",hba_link_failures,table)
      hba_sync_losses=get_hba_sync_losses(io_path,controller_no)
      table=handle_output("row","Sync Losses",hba_sync_losses,table)
      hba_signal_losses=get_hba_signal_losses(io_path,controller_no)
      table=handle_output("row","Signal Losses",hba_signal_losses,table)
      hba_protocol_errors=get_hba_protocol_errors(io_path,controller_no)
      table=handle_output("row","Protocol Errors",hba_protocol_errors,table)
      hba_invalid_tx=get_hba_invalid_tx(io_path,controller_no)
      table=handle_output("row","Invalid Tx Words",hba_invalid_tx,table)
      hba_invalid_crc=get_hba_invalid_crc(io_path,controller_no)
      table=handle_output("row","Invalid CRC",hba_invalid_crc,table)
    end
    fcode_version=get_hba_fcode(io_path)
    table=handle_output("row","FCode",fcode_version,table)
    hba_part_info=$hba_part_list[io_name]
    hba_part_info=hba_part_info.split(/,/)
    hba_part_no=hba_part_info[0]
    hba_part_description=hba_part_info[1]
    table=handle_output("row","Part Number",hba_part_no,table)
    if io_path.match(/emlxs/)
      table=process_avail_emulex_firmware(table,io_name,hba_firmware_version)
    end
    if io_path.match(/qlc/)
      table=process_avail_qlogic_firemware(table,hba_part_no,hba_firmware_version)
    end
    table=handle_output("row","Part Description",hba_part_description,table)
  end
  if io_path.match(/emlxs|qlc|scsi/)
    if $do_disks == 1
      process_disk_info(table,controller_no)
    end
  end
  return table
end

# Get the Time Zone

def get_time_zone()
  file_name="/etc/TIMEZONE"
  file_array=explorer_file_to_array(file_name)
  if !file_array
    time_zone=""
  else
    time_zone=file_array.grep(/^TZ/)[0].split("=")[1].chomp
  end
  return time_zone
end

# Process Time Zone

def process_time_zone(table)
  time_zone=get_time_zone()
  if $masked == 0
    table=handle_output("row","Timezone",time_zone,table)
  else
    table=handle_output("row","Timezone","Country/State",table)
  end
  return table
end

# Get the chassis serial number.

def get_chassis_serial()
  file_name="/sysconfig/chassis_serial.out"
  file_array=explorer_file_to_array(file_name)
  if !file_array
    serial_number=""
  else
    serial_number=file_array[0].to_s
  end
  return serial_number
end

# Process chassis serial number

def process_chassis_serial(table)
  serial_number=get_chassis_serial()
  if $masked == 0
    table=handle_output("row","Serial",serial_number,table)
  else
    table=handle_output("row","Serial","XXXXXXXX",table)
  end
  return table
end

# Get the controller number.
# Use information in the IO path name to get information.

def get_controller_no(io_path)
  controller_no=""
  # Handle FC devices
  if io_path.match(/emlxs|scsi/)
    # Get controller name by searching dev list for IO path
    # We do this as the kernel driver in path_to_inst is fp
    # whereas the controller is cX in everything else
    file_name="/disks/ls-l_dev_cfg.out"
    file_array=explorer_file_to_array(file_name)
    controller_no=file_array.grep(/#{io_path}/)
    controller_no=controller_no.to_s.split(" ")
    controller_no=controller_no[8].to_s
  end
  return controller_no
end

# Process controller number

def process_controller_no(table,io_path)
  controller_no=get_controller_no(io_path)
  table=handle_output("row","Controller",controller_no,table)
  return table
end

# Get the IO slot number.
# http://docs.oracle.com/cd/E19415-01/E21618-01/App_DevicePaths.html

def get_io_slot(io_path,io_type,system_model)
  controller_no=get_controller_no(io_path)
  io_unit=io_path.split("/")
  io_unit=io_unit[1].to_s
  if io_unit.match(/0\,6/)
    if io_type.match(/PCIx/)
      io_slot=0
    else
      io_slot=1
    end
  end
  if io_unit.match(/1\,7/)
    io_slot=2
  end
  if io_unit.match(/2\,6/)
    io_slot=3
  end
  if io_unit.match(/3\,7/)
    io_slot=4
  end
  return io_slot.to_s
end

# Handle prtdiag IO information.
# Return IO type.

def handle_prtdiag_io(line,system_model)
  hw_info=line.split(/\s+/)
  if system_model.match(/M5000/)
    if hw_info[0].to_s.match(/^0/)
      io_unit=hw_info[0].to_s
      io_type=hw_info[1].to_s
      handle_output("IOU",io_unit)
      handle_output("Bus",io_type)
    end
  end
  if system_model.match(/V440/)
  end
  return io_type
end

# Get the System model

def get_system_model()
  file_name="/sysconfig/prtdiag-v.out"
  file_array=explorer_file_to_array(file_name)
  system_model=file_array.grep(/^System Configuration:/)
  system_model=system_model[0]
  system_model=system_model.split(": ")
  system_model=system_model[1]
  system_model=system_model.chomp
  system_model=system_model.gsub("sun4u","")
  system_model=system_model.gsub("sun4v","")
  system_model=system_model.gsub(/^ /,"")
  system_model=system_model.gsub(/\s+/," ")
  return system_model
end

# Get the System memory

def get_system_memory()
  file_name="/sysconfig/prtdiag-v.out"
  file_array=explorer_file_to_array(file_name)
  system_memory=file_array.grep(/^Memory size:/)
  system_memory=system_memory[0]
  system_memory=system_memory.split(": ")
  system_memory=system_memory[1]
  system_memory=system_memory.chomp
  return system_memory
end

# Search prtdiag

def search_prtdiag_info(search_value)
  prtdiag_output=0
  prtdiag_info=Array.new
  file_name="/sysconfig/prtdiag-v.out"
  file_array=explorer_file_to_array(file_name)
  file_array.each do |line|
    if prtdiag_output == 1
      if line.match(/^=/)
        prtdiag_output=0
      else
        prtdiag_info.push(line)
      end
    end
    if line.match(/#{search_value}/)
      prtdiag_output=1
    end
  end
  return prtdiag_info
end

# Process System Model

def process_system_model(table)
  system_model=get_system_model()
  table=handle_output("row","Model",system_model,table)
  return table
end

# Process System Memory

def process_system_memory(table)
  system_memory=get_system_memory()
  table=handle_output("row","Memory",system_memory,table)
  return table
end

# Get CPU information

def get_cpu_info()
  cpu_info=search_prtdiag_info("CPUs")
  return cpu_info
end

# Get CPU family

def get_cpu_type(cpu_id)
  no_zeros=8-cpu_id.length
  cpu_id="0"*no_zeros+cpu_id
  cpu_type=""
  file_name="/sysconfig/prtconf-vp.out"
  file_array=explorer_file_to_array(file_name)
  file_array.each do |line|
    line.chomp
    if line.match(/compatible:/)
      if line.match(/SPARC/)
        cpu_type=line.split(": '")
        cpu_type=cpu_type[1]
        cpu_type=cpu_type.split(",")
        cpu_type=cpu_type[1]
        cpu_type=cpu_type.gsub("'","")
        cpu_mask=cpu_type[5]
      end
    end
    if line.match(/cpuid:/)
      if line.match(/#{cpu_id}/)
        return cpu_type
      end
    end
  end
end

# Process CPU information

def process_cpu_info()
  table=handle_output("title","CPU Information","","")
  cpu_info=get_cpu_info()
  system_model=get_system_model()
  cpu_info.each do |line|
    system_board_no="1"
    cpu_no=""
    if line.match(/[0-9][0-9]/)
      if system_model.match(/V4/)
        if line.match(/^[0-9]/)
          cpu_line=line.split(/\s+/)
          cpu_no=cpu_line[0].to_s
          cpu_speed=cpu_line[1]+" MHz"
          cpu_cache=cpu_line[3]
          cpu_type=cpu_line[4].split(/,/)[1]
          cpu_mask=cpu_line[5]
          cpu_list="0"
        end
      end
      if system_model.match(/M[3-9]0/)
        if line.match(/^ [0-9]/)
          cpu_list=""
          cpu_line=line.split(/\s+/)
          cpu_no=cpu_line[2]
          cpu_mask=cpu_line[-1]
          cpu_cache=cpu_line[-3]
          cpu_speed=cpu_line[-4]+" MHz"
          system_board_no=cpu_line[1]
          cpu_ids=line.split(/(?<=,)/)
          cpu_ids.each do |cpu_id|
            if cpu_id.match(/,$/)
              cpu_id=cpu_id.split(/\s+/)
              cpu_id=cpu_id[-1]
            else
              cpu_id=cpu_id.gsub(/^\s+/,"")
              cpu_id=cpu_id.split(/\s+/)
              cpu_id=cpu_id[0]
            end
            cpu_list=cpu_list+cpu_id
          end
          cpu_ids=cpu_list.split(",")
          cpu_id=cpu_ids[0]
          cpu_id=cpu_id.to_i.chr.unpack('H*')
          cpu_id=cpu_id[0]
          cpu_type=get_cpu_type(cpu_id)
    #     cpu_family=get_cpu_family(cpu_mask)
        end
      end
      table=handle_output("row","System Board",system_board_no,table)
      table=handle_output("row","Socket",cpu_no,table)
      table=handle_output("row","Mask",cpu_mask,table)
      table=handle_output("row","Speed",cpu_speed,table)
      table=handle_output("row","Cache",cpu_cache,table)
      table=handle_output("row","IDs",cpu_list,table)
      table=handle_output("row","Type",cpu_type,table)
    end
  end
  table=handle_output("end","","",table)
  return
end
# Get memory information

def get_memory_info
  memory_info=search_prtdiag_info("Memory Configuration")
  return memory_info
end

# Process Memory information

def process_memory_info()
  table=handle_output("title","Memory Information","","")
  memory_info=get_memory_info()
  system_model=get_system_model()
  memory_info.each do |line|
    if line.match(/[0-9][0-9]/)
      system_board_no="1"
      memory_line=line.split(/\s+/)
      if system_model.match(/M[3-9]0/)
        system_board_no=memory_line[1]
        memory_group=memory_line[2]
        memory_size=memory_line[3]
        memory_status=memory_line[4]
        memory_dimm_size=memory_line[5]
        memory_dimms=memory_line[6]
        memory_mirror=memory_line[7]
        memory_interleave=memory_line[8]
      end
      if system_model.match(/V4/)
        memory_status="N/A"
        memory_mirror="N/A"
        if line.match(/^0x/)
          memory_group_no=memory_line[0].split(/x/)[1]
          memory_group_no=memory_group_no.gsub(/000000000/,'')
          memory_size=memory_line[1]
          memory_interleave=memory_line[2]
          memory_dimms=memory_line[4]
          memory_dimm_no=memory_dimms.split(/,/)[0]
          if line.match(/^0x0/)
            memory_search=memory_dimms
          end
          file_name="/sysconfig/prtdiag-v.out"
          file_array=explorer_file_to_array(file_name)
          memory_dimm_size=file_array.grep(/#{memory_search}/)
          memory_dimm_size=memory_dimm_size.grep(/MB/)
          memory_dimm_size=memory_dimm_size.grep(/^#{memory_dimm_no}/)[0].split(/\s+/)[3]
          memory_group=file_array.grep(/C[0-9]\/P[0-9]/)
          memory_group=memory_group.grep(/^#{memory_group_no}/)
          memory_group_list=""
          memory_group.each do |memory_group_line|
            memory_list=memory_group_line.split(/\s+/)[2]
            if memory_group_list.match(/C/)
              memory_group_list=memory_group_list+" "+memory_list
            else
              memory_group_list=memory_list
            end
          end
          memory_group=memory_group_list
        end
      end
      if memory_size
        table=handle_output("row","System Board",system_board_no,table)
        table=handle_output("row","Group(s)",memory_group,table)
        table=handle_output("row","Size",memory_size,table)
        table=handle_output("row","Status",memory_status,table)
        table=handle_output("row","DIMMs",memory_dimms,table)
        table=handle_output("row","DIMM Size",memory_dimm_size,table)
        table=handle_output("row","Mirror",memory_mirror,table)
        table=handle_output("row","Interleave",memory_interleave,table)
      end
    end
  end
  table=handle_output("end","","",table)
  return
end

# Get IO information

def get_io_info()
  io_info=search_prtdiag_info("IO Devices")
  return io_info
end

# Get driver info
# Uses path_to_inst to get driver name

def get_driver_info(io_path)
  file_name="/etc/path_to_inst"
  file_array=explorer_file_to_array(file_name)
  return(file_array)
end

# Process driver info

def process_driver_info(io_path)
  driver_info=get_driver_info(io_path)
  if io_path.match(/emlxs/)
    io_path=io_path+"/fp@0,0"
  end
  driver_info=driver_info.grep(/"#{io_path}"/)
  driver_info=driver_info[0].split(" ")
  instance_no=driver_info[1]
  driver_name=driver_info[2].to_s.gsub(/\"/,'')
  device_name=driver_name+instance_no
  return device_name,driver_name,instance_no
end

# Get aggregate information

def get_aggr_info()
  file_name="/etc/aggregation.conf"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Get /etc/system info

def get_etc_system_info()
  file_name="/etc/system"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process /etc/system info

def process_etc_system_info()
  table=handle_output("title","Kernel Parameter Information","","")
  etc_system_info=get_etc_system_info()
  etc_system_info.each do |line|
    line=line.chomp
    if line.to_s.match(/^[A-z]/)
      if line.to_s.match(/[A-z]/)
        if line.to_s.match(/\=/)
          line=line.split("=")
        else
          line=line.split(":")
        end
        item_name=line[0]
        item_name=item_name.gsub(/set /,'')
        item_name=item_name.gsub(/ $/,'')
        item_value=line[1].gsub(/^ /,'')
      end
      if item_name.to_s.match(/[A-z]/)
        table=handle_output("row",item_name,item_value,table)
      end
    end
  end
  table=handle_output("end","","",table)
  return
end

# Process aggregate information

def process_aggr_info(device_name)
  aggr_name=""
  aggr_info=get_aggr_info()
  if aggr_info
    aggr_no=aggr_info.grep(/#{device_name}/)
    aggr_no=aggr_no[0].to_s.split(/\s+/)
    aggr_no=aggr_no[0].to_s
    if aggr_no.match(/[0-9]/)
      aggr_name="aggr"+aggr_no
    else
      aggr_name=""
    end
  end
  return aggr_name
end

# Get interface hostname

def get_interface_hostname_info(interface_name)
  file_name="/etc/hostname."+interface_name
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process interface hostname

def get_interface_hostname(interface_name)
  interface_hostname=get_interface_hostname_info(interface_name)
  if interface_hostname.to_s.match(/[A-z]/)
    if interface_hostname.grep(/failover/)
      interface_hostname=interface_hostname.join.split(/ /)[0].to_s
    end
  else
    interface_hostname=""
  end
  return interface_hostname
end

# Get ip from hostname

def get_hostname_ip(hostname)
  hostname_ip=""
  file_name="/etc/inet/hosts"
  file_array=explorer_file_to_array(file_name)
  hostname_ip=file_array.grep(/#{hostname}/)
  hostname_ip=hostname_ip[0].to_s.split(/\s+/)[0]
  return hostname_ip
end

# Process IO information

def process_io_info()
  table=handle_output("title","IO Information","","")
  io_info=get_io_info()
  counter=0
  io_count=0
  system_model=get_system_model()
  io_length=io_info.select{|line| line.match(/^[0-9]|^pci/)}.length
  io_info.each do |line|
    #puts line
    counter=counter+1
    if line.match(/^[0-9]|^pci/)
      io_count=io_count+1
      io_line=line.chomp
      io_line=line.split(/\s+/)
      system_board_no=io_line[0]
      if system_model.match(/M[3-9]0/)
        table=handle_output("row","IOU",system_board_no,table)
        io_type=io_line[1]
      else
        io_type=io_line[0]
        io_speed=io_line[1]
        table=handle_output("row","Speed",io_speed,table)
        io_type=io_line[0]
      end
      table=handle_output("row","Type",io_type,table)
      io_name=io_line[-1]
      table=handle_output("row","Name",io_name,table)
      io_path=io_info[counter]
      io_path=io_path.to_s
      io_path=io_path.gsub(/\s+/,'')
      io_path=io_path.gsub(/okay/,'')
      table=handle_output("row","Path",io_path,table)
      if system_model.match(/M[3-9]0/)
        io_slot=get_io_slot(io_path,io_type,system_model)
      else
        io_slot=io_line[2]
      end
      table=handle_output("row","Slot",io_slot,table)
      controller_no=get_controller_no(io_path)
      if controller_no.match(/[0-9]/)
        table=handle_output("row","Controller",controller_no,table)
      end
      (device_name,driver_name,instance_no)=process_driver_info(io_path)
      table=handle_output("row","Driver",driver_name,table)
      table=handle_output("row","Instance",instance_no,table)
      if io_path.match(/network/)
        port_no=io_path[-1]
        table=handle_output("row","Port",port_no,table)
        aggr_name=process_aggr_info(device_name)
        if aggr_name.match(/[A-z]/)
          table=handle_output("row","Aggregate",aggr_name,table)
          interface_hostname=get_interface_hostname(aggr_name)
        else
          interface_name=driver_name+instance_no
          if $maked == 0
            table=handle_output("row","Interface",interface_name,table)
          else
            table=handle_output("row","Interface","xxxxxxxx",table)
          end
          interface_hostname=get_interface_hostname(interface_name)
        end
        if interface_hostname.match(/[A-z]/)
          if $masked == 0
            table=handle_output("row","Hostname",interface_hostname,table)
          else
            table=handle_output("row","Hostname","xxxxxxxx",table)
          end
          interface_ip=get_hostname_ip(interface_hostname)
          if interface_ip
            if $masked == 0
              table=handle_output("row","IP",interface_ip,table)
            else
              table=handle_output("row","IP","XXX.XXX.XXX.XXX",table)
            end
          end
        end
      end
      table=process_controller_info(table,io_name,io_path,controller_no)
    end
    if line.match(/^[0-9]|^pci/) and io_count != io_length-2
      table=handle_output("line","","",table)
    end
  end
  table=handle_output("end","","",table)
  return
end

# Search file name

def search_file_name(field)
  field_value=Pathname.new($explorer_file)
  field_value=field_value.basename
  field_value=field_value.to_s.split(".")
  field_value=field_value[field].to_s
  return field_value
end

# Process file name

def process_file_name(table)
  file_name=Pathname.new($explorer_file)
  file_name=file_name.basename.to_s
  if $masked == 0
    table=handle_output("row","File",file_name,table)
  else
    table=handle_output("row","File","explorer.tar.gz",table)
  end
  return table
end

# Process explorer directory

def process_dir_name(table)
  table=handle_output("row","Directory",$explorer_dir,table)
  return table
end

# Get file date

def get_file_date()
  file_year=search_file_name(2)
  file_year=file_year.to_s.split("-")
  file_year=file_year[1].to_s
  file_month=search_file_name(3)
  file_day=search_file_name(4)
  file_date=file_day+"/"+file_month+"/"+file_year
  return file_date
end

def process_file_date(table)
  file_date=get_file_date()
  table=handle_output("row","Date",file_date,table)
  return table
end

# Get Sys/Host ID

def get_host_id()
  host_id=search_file_name(1).to_s
  return host_id
end

def process_host_id(table)
  host_id=get_host_id()
  if $masked == 0
    table=handle_output("row","HostID",host_id,table)
  else
    table=handle_output("row","HostID","XXXXXXXX",table)
  end
  return table
end

# Get file time

def get_file_time()
  file_hour=search_file_name(5)
  file_min=search_file_name(6)
  file_hour=file_hour.to_s
  file_min=file_min.to_s
  file_time=file_hour+":"+file_min
  return file_time
end

def process_file_time(table)
  file_time=get_file_time()
  table=handle_output("row","Time",file_time,table)
  return table
end

# Get hostname

def get_host_name()
  host_name=search_file_name(2)
  host_name=host_name.to_s.split("-")
  host_name=host_name[0].to_s
  return host_name
end

def process_host_name(table)
  host_name=get_host_name()
  if $masked == 0
    table=handle_output("row","Hostname",host_name,table)
  else
    table=handle_output("row","Hostname","explorer-host",table)
  end
  return table
end

# Search uname info

def search_uname(field)
  file_name="/sysconfig/uname-a.out"
  file_array=explorer_file_to_array(file_name)
  uname_array=file_array[0]
  uname_array=uname_array.split(" ")
  os_name=uname_array[field]
  return os_name
end

# Get OS name

def get_os_name()
  os_name=search_uname(0)
  return os_name
end

def process_os_name(table)
  os_name=get_os_name()
  table=handle_output("row","OS Name",os_name,table)
  return table
end

# Get  OS version

def get_os_version()
  os_version=search_uname(2)
  return os_version
end

def process_os_version(table)
  os_version=get_os_version()
  table=handle_output("row","OS Version",os_version,table)
  return table
end

# Get kernel version

def get_kernel_version()
  kernel_version=search_uname(3)
  return kernel_version
end

def process_kernel_version(table)
  kernel_version=get_kernel_version()
  table=handle_output("row","Kernel Version",kernel_version,table)
  return table
end

# Get Architecture

def get_arch_name()
  arch_name=search_uname(4)
  return arch_name
end

def process_arch_name(table)
  arch_name=get_arch_name()
  table=handle_output("row","Architecture",arch_name,table)
  return table
end

# Get number of cores

def get_core_no()
  file_name="/sysconfig/uname-X.out"
  file_array=explorer_file_to_array(file_name)
  core_no=file_array.grep(/^NumCPU/)
  core_no=core_no[0].to_s.split(" = ")
  core_no=core_no[1]
  return core_no
end

# Process number of cores

def process_core_no(table)
  core_no=get_core_no()
  table=handle_output("row","Cores",core_no,table)
  return table
end

# Get disk information

def get_disk_info(disk_name)
  file_name="/sysconfig/iostat-En.out"
  file_array=explorer_file_to_array(file_name)
  disk_info=file_array.join.split(/Analysis:/)
  if disk_name != "all"
    disk_info=disk_info.grep(/#{disk_name}/)
  end
  return disk_info
end

#  Get Disk Index Number - Used to look up sd info

def get_disk_index(disk_name)
  file_name="/sysconfig/iostat-En.out"
  file_array=explorer_file_to_array(file_name)
  disk_info=file_array.join.split(/Analysis:/)
  disk_info.each_with_index do |disk_data, disk_index|
    if disk_data.match(/#{disk_name} /)
      return disk_index
    end
  end
end

# Process disk information

def process_disk_info(table,disk_name)
  disk_info=get_disk_info(disk_name)
  disk_info.each do |disk_data|
    disk_data=disk_data.gsub(/\n/,'')
    disk_data=disk_data.split(/:/)
    disk_id=disk_data[0].split(/\s+/)[2]
    if !disk_id.match(/#{disk_name}/)
      disk_id=disk_data[0].split(/\s+/)[0]
    end
    table=handle_output("row","Disk",disk_id,table)
    disk_vendor=disk_data[4].split(/ Product/)[0].gsub(/\s+/,'')
    table=handle_output("row","Vendor",disk_vendor,table)
    disk_model=disk_data[5].split(/ Revision/)[0].gsub(/^\s+/,'').gsub(/\s+/,' ')
    table=handle_output("row","Model",disk_model,table)
    if disk_model.match(/CD|DVD/)
      disk_serial="N/A"
    else
      disk_serial=disk_data[7].split(/ Size/)[0].gsub(/\s+/,'')
      disk_path=get_disk_path(disk_id)
      table=handle_output("row","Path",disk_path,table)
    end
    disk_firmware=disk_data[6].split(/ Serial/)[0].gsub(/\s+/,'')
    table=handle_output("row","Installed Firmware",disk_firmware,table)
    # Remove SUN* from Disk Model
    # E.g. ST914602SSUN146G -> ST914602S
    if disk_model.match(/SUN/)
      disk_model=disk_model.split(/SUN/)[0]
    end
    if !disk_firmware.match(/0000/)
      table=process_avail_disk_firmware(table,disk_model,disk_firmware)
    end
    if disk_serial.match(/[0-9]/)
      if $masked == 0
        table=handle_output("row","Serial",disk_serial,table)
      else
        table=handle_output("row","Serial","XXXXXXXX",table)
      end
    end
    disk_size=disk_data[8].split(/ </)[0].gsub(/\s+/,'')
    table=handle_output("row","Size",disk_size,table)
    disk_index=get_disk_index(disk_id)
    process_disk_sd_info(table,disk_index)
    process_disk_meta_db(table,disk_id)
    process_disk_meta_device(table,disk_id)
    process_vfstab_info(table,disk_id)
    process_vx_disk_info(table,disk_id)
    process_vx_device_info(table,disk_id)
  end
  return table
end

# Get Veritas paths

def get_vx_disk_alt_path(vx_disk_name)
  file_name="/disks/vxvm/vxdisk_path.out"
  file_array=explorer_file_to_array(file_name)
  vx_disk_info=file_array.grep(/#{disk_name}s2/)
  return vx_disk_info
end

# Get Veritas Enclosure Name

def get_vx_encl_name(disk_name)
  file_name="/disks/vxvm/vxdmpadm_listctlr_all.out"
  file_array=explorer_file_to_array(file_name)
  if disk_name.match(/t/)
    disk_name=disk_name.split(/t/)[0]
  end
  vx_encl_name=file_array.grep(/^#{disk_name} /)
  vx_encl_name=vx_encl_name[0].split(/\s+/)
  vx_encl_name=vx_encl_name[3]
  return vx_encl_name
end

# Get Veritas device information

def get_vx_device_info(disk_name)
  file_name="/disks/vxvm/disks/vxdisk_list=#{disk_name}s2.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process Veritas device information

def process_vx_device_info(table,disk_name)
  vx_device_info=get_vx_device_info(disk_name)
  counter=0
  vx_device_info.each do |vx_line|
    if vx_line.match(/:/)
      vx_line=vx_line.split(/:/)
      vx_info=vx_line[1].gsub(/^\s+/,'')
      if vx_line[0].match(/^flags/)
        table=handle_output("row","Veritas Flags",vx_info,table)
      end
      if vx_line[0].match(/^pubpaths/)
        vx_paths=vx_info.split(/\s+/)
        vx_block=vx_paths[0].split(/\=/)[1]
        vx_raw=vx_paths[1].split(/\=/)[1]
        table=handle_output("row","Veritas Block Device",vx_block,table)
        table=handle_output("row","Veritas Raw Device",vx_raw,table)
      end
      if vx_line[0].match(/^iosize/)
        vx_iosize=vx_info.split(/\s+/)
        vx_min=vx_iosize[0].split(/\=/)[1]+" "+vx_iosize[1]
        vx_max=vx_iosize[2].split(/\=/)[1]+" "+vx_iosize[3]
        table=handle_output("row","Veritas Minimum IO Size",vx_min,table)
        table=handle_output("row","Veritas Maximum IO Size",vx_max,table)
      end
      if vx_line[0].match(/^guid/)
        vx_info=vx_info.gsub(/\{/,'')
        vx_info=vx_info.gsub(/\}/,'')
        table=handle_output("row","Veritas GUID",vx_info,table)
      end
      if vx_line[0].match(/^uuid/)
        table=handle_output("row","Veritas UUID",vx_info,table)
      end
      if vx_line[0].match(/^numpaths/)
        table=handle_output("row","Veritas Paths",vx_info,table)
        if vx_info.match(/2/)
          vx_alt_path=vx_device_info[counter+2].split(/\s+/)[0]
          vx_alt_path="/dev/vx/dmp/"+vx_alt_path
          table=handle_output("row","Veritas Alternate Path",vx_alt_path,table)
        end
      end
      if vx_line[0].match(/^version/)
        table=handle_output("row","Veritas Volume Version",vx_info,table)
      end
      counter=counter+1
    end
  end
  return table
end

# Get Veritas disk information

def get_vx_disk_info(disk_name)
  file_name="/disks/vxvm/vxdisk-list.out"
  file_array=explorer_file_to_array(file_name)
  vx_disk_info=file_array.grep(/#{disk_name}s2/)
  if !vx_disk_info.to_s.match(/c[0-9]/)
    file_name="/disks/vxvm/vxdisk_path.out"
    file_array=explorer_file_to_array(file_name)
    vx_disk_info=file_array.grep(/#{disk_name}s2/)
  end
  return vx_disk_info
end

# Process Veritas Disk information

def process_vx_disk_info(table,disk_name)
  vx_disk_info=get_vx_disk_info(disk_name)
  vx_disk_info.each do |vx_line|
  vx_line=vx_line.split(/\s+/)
    vx_type=vx_line[1]
    vx_disk=vx_line[2]
    vx_group=vx_line[3]
    vx_status=vx_line[4]
    vx_features=vx_line[5]
    if vx_type
      if vx_type.match(/:/)
        table=handle_output("row","Veritas Type",vx_type,table)
      else
        if vx_type.match(/^c/)
          if vx_type != vx_disk
            table=handle_output("row","Veritas Type","Alternate Path for #{vx_type}",table)
          end
        end
      end
    end
    if vx_disk
      if vx_disk.match(/[A-z]/)
        table=handle_output("row","Veritas Disk Name",vx_disk,table)
      end
    end
    if vx_group
      if vx_group.match(/[A-z]/)
        vx_group=vx_group.gsub(/\(/,'').gsub(/\)/,'')
        table=handle_output("row","Veritas Disk Group",vx_group,table)
      end
    end
    if vx_status
      table=handle_output("row","Veritas Status",vx_status,table)
    end
    if vx_features
      if !vx_features.match(/^c[0-9]/)
        table=handle_output("row","Veritas Features",vx_features,table)
      end
    end
    vx_encl_name=get_vx_encl_name(disk_name)
    if vx_encl_name
      table=handle_output("row","Veritas Enclosure",vx_encl_name,table)
    end
  end
  return table
end

# Get file system mount point and filesystem insformation

def get_vfstab_info(search)
  file_name="/etc/vfstab"
  file_array=explorer_file_to_array(file_name)
  vfstab_info=file_array.grep(/#{search}/)
  return vfstab_info
end

def process_vfstab_info(table,search)
  vfstab_info=get_vfstab_info(search)
  vfstab_info.each do |fs_line|
    if !fs_line.match(/^#/)
      fs_line=fs_line.split(/\s+/)
      mount_point=fs_line[2]
      file_system=fs_line[3]
      if file_system.match(/swap/)
        mount_point="/tmp"
      end
      if $masked == 0
        table=handle_output("row","Mount Point",mount_point,table)
        table=handle_output("row","Filesystem",file_system,table)
      else
        table=handle_output("row","Mount Point","/mount",table)
        table=handle_output("row","Filesystem",file_system,table)
      end
    end
  end
  return table
end

# Get disk metaslice

def get_disk_meta_device(disk_name)
  file_name="/disks/svm/metastat-p.out"
  file_array=explorer_file_to_array(file_name)
  if disk_name.match(/^c/)
    disk_info=file_array.grep(/#{disk_name}/)
  else
    disk_info=file_array.grep(/ #{disk_name} /)
  end
  return disk_info
end

# Process metaslices

def process_disk_meta_device(table,disk_name)
  disk_info=get_disk_meta_device(disk_name)
  disk_info.each do |disk_meta_slice|
    meta_device_info=disk_meta_slice.split(/\s+/)
    meta_device=meta_device_info[0]
    disk_slice=meta_device_info[-1]
    table=handle_output("row","Meta Device",meta_device,table)
    table=handle_output("row","Disk Slice",disk_slice,table)
    meta_device=get_disk_meta_device(meta_device)
    meta_device=meta_device.join.split(/\s+/)[0]
    process_vfstab_info(meta_device)
  end
  return table
end

# Get disk metabdb

def get_disk_meta_db(disk_name)
  file_name="/disks/svm/metadb.out"
  file_array=explorer_file_to_array(file_name)
  disk_info=file_array.grep(/#{disk_name}/)
  return disk_info
end

# Process metadbs

def process_disk_meta_db(table,disk_name)
  disk_info=get_disk_meta_db(disk_name)
  disk_info.each do |disk_meta_db|
    meta_db_info=disk_meta_db.split(/\s+/)
    meta_db_start=meta_db_info[4]
    meta_db_size=meta_db_info[5]
    meta_db_device=meta_db_info[-1]
    meta_db_device=File.basename(meta_db_device)
    table=handle_output("row","MetaDB Device",meta_db_device,table)
    table=handle_output("row","MetaDB Start",meta_db_start,table)
    table=handle_output("row","MetaDB Size",meta_db_size,table)
  end
  return table
end

# Get Disk sd information

def get_disk_sd_info(counter)
  file_name="/disks/iostat-iE.out"
  file_array=explorer_file_to_array(file_name)
  disk_info=file_array.join.split(/Analysis:/)
  if counter != "all"
    disk_info=disk_info[counter]
  end
  return disk_info
end

# Handle disk sd information

def handle_disk_sd_info(table,disk_data)
  disk_data=disk_data.gsub(/\n/,'')
  disk_data=disk_data.split(/:/)
  disk_id=disk_data[0].split(/\s+/)[2]
  if !disk_id.match(/^sd|^ssd/)
    disk_id=disk_data[0].split(/\s+/)[0]
  end
  table=handle_output("row","SD Name",disk_id,table)
  return table
end

# Process Disk sd information

def process_disk_sd_info(table,counter)
  sd_info=get_disk_sd_info(counter)
  if sd_info.is_a? Array
    sd_info.each do |disk_data|
      handle_disk_sd_info(table,disk_data)
    end
  else
    handle_disk_sd_info(table,sd_info)
  end
  return table
end

# Get disk path

def get_disk_path(disk_name)
  file_name="/disks/format.out"
  file_array=explorer_file_to_array(file_name)
  disk_info=file_array.grep(/[0-9]/)
  disk_info=disk_info.join.split(/\. /)
  disk_info=disk_info.grep(/#{disk_name} /)
  disk_info=disk_info[0].split(/\n/)
  disk_info=disk_info[1].gsub(/\s+/,'')
  return disk_info
end

# Process the OS release information.

def get_os_update()
  os_version=get_os_version()
  os_date=get_os_date()
  os_build=get_os_build()
  if os_build.match(/_u/)
    os_update=os_build.split(/_/)[1].gsub(/[A-z]/,'')
  end
  if os_version.match("10")
    case os_date
    when "1/06"
      os_update="1"
    when "6/06"
      os_update="2"
    when "11/06"
      os_update="3"
    when "8/07"
      os_update="4"
    when "5/08"
      os_update="5"
    when "10/08"
      os_update="6"
    when "5/09"
      os_update="7"
    when "10/09"
      os_update="8"
    when "9/10"
      os_update="9"
    when "1/06"
      os_update="10"
    when "1/06"
      os_update="11"
    end
  end
  return os_update
end

def process_os_update(table)
  os_update=get_os_update()
  table=handle_output("row","OS Update",os_update,table)
  return table
end

# Search release info

def search_release(field)
  file_name="/etc/release"
  file_array=explorer_file_to_array(file_name)
  release_array=file_array[0]
  if release_array.match(/HW/)
    field=field+1
  end
  release_array=release_array.split(" ")
  search_result=release_array[field].to_s
  return search_result
end

# Get OS build

def get_os_build()
  os_build=search_release(3)
  return os_build
end

def process_os_build(table)
  os_build=get_os_build()
  table=handle_output("row","OS Build",os_build,table)
  return table
end

# Get OS date

def get_os_date()
  os_date=search_release(2)
  return os_date
end

def process_os_date(table)
  os_date=get_os_date()
  table=handle_output("row","OS Release",os_date,table)
  return table
end

# Process the Zone information.

def process_zones()
  table=handle_output("title","Zone Information","","")
  file_name="/sysconfig/zoneadm-list-iv.out"
  file_array=explorer_file_to_array(file_name)
  file_array.each do |line|
    table=handle_output("row","Zone",line,table)
  end
  table=handle_output("end","","",table)
end

# Process explorer version.

def process_explorer_version(table)
  explorer_version=get_explorer_version()
  table=handle_output("row","STB Version",explorer_version,table)
  return table
end

# Get system boot time

def get_system_boot()
  file_name="/sysconfig/who-b.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process system boot time

def process_system_boot(table)
  boot_time=get_system_boot()
  boot_time=boot_time[0].to_s.split(/boot/)
  boot_time=boot_time[1].to_s.gsub(/^\s+/,'').chomp
  file_date=get_extracted_file_date("/sysconfig/who-b.out")
  file_year=file_date.to_s.split(/ /)[0].split(/-/)[0].chomp
  boot_time=boot_time+" "+file_year
  if $masked == 0
    table=handle_output("row","Boot Time",boot_time,table)
  else
    date=`date`
    table=handle_output("row","Boot Time",date,table)
  end
  return table
end

# Get explorer version.

def get_explorer_version()
  file_name="/rev"
  file_array=explorer_file_to_array(file_name)
  explorer_version=file_array[0].to_s
  return explorer_version
end

# Get available M series OBP version

def get_avail_obp_version(model_name)
  avail_obp=""
  if model_name.match(/^M[3-9]/)
    file_name="xscf_firmware"
    fw_info=info_file_to_array(file_name)
    fw_info.each do |line|
      line.chomp
      data=line.split(/,/)
      if data[0] == model_name
        avail_obp=data[1].split(/ /)[5]
      end
    end
  end
  return avail_obp
end

# Process OBP version.

def process_obp_version(table)
  obp_version=get_obp_version()
  if $host_info["Model"].match(/M[3-9]/)
    model_name=$host_info["Model"].split(/ /)[5]
    current_obp=obp_version.split(/ /)[1]
  end
  avail_obp=get_avail_obp_version(model_name)
  current_version=Versionomy.parse(current_obp)
  avail_version=Versionomy.parse(avail_obp)
  if avail_version > current_version
    avail_obp=avail_obp+" (Newer)"
  end
  avail_obp="OBP "+avail_obp
  table=handle_output("row","OBP Version",obp_version,table)
  table=handle_output("row","Available OBP Version",avail_obp,table)
  return table
end

# Get OBP version.

def get_obp_version()
  file_name="/sysconfig/prtconf-V.out"
  file_array=explorer_file_to_array(file_name)
  obp_version=file_array[0].to_s
  return obp_version
end

def get_customer_name()
  file_name="/defaults"
  file_array=explorer_file_to_array(file_name)
end

def search_explorer_defaults(search_value)
  file_name="/defaults"
  file_array=explorer_file_to_array(file_name)
  file_array.each do |line|
    if !line.match(/^#/)
      explorer_info=line.split("=")
      explorer_value=explorer_info[1].to_s.gsub(/"/,"")
      explorer_info=explorer_info[0].to_s
      if explorer_info.match(/#{search_value}/)
        return explorer_value
      end
    end
  end
end

# Get customer name

def get_customer_name()
  customer_name=search_explorer_defaults("EXP_CUSTOMER_NAME")
  return customer_name
end

def process_customer_name(table)
  customer_name=get_customer_name()
  if $masked == 0
    table=handle_output("row","Customer",customer_name,table)
  else
    table=handle_output("row","Customer","Company X",table)
  end
  return table
end

# Get contract ID

def get_contract_id()
  contract_id=search_explorer_defaults("EXP_CONTRACT_ID")
  return contract_id
end

def process_contract_id(table)
  contract_id=get_contract_id()
  table=handle_output("row","Contract ID",contract_id,table)
  return table
end

# Get Explorer User

def get_explorer_user()
  explorer_user=search_explorer_defaults("EXP_USER_NAME")
  return explorer_user
end

def process_explorer_user(table)
  explorer_user=get_explorer_user()
  if $masked == 0
    table=handle_output("row","User",explorer_user,table)
  else
    table=handle_output("row","User","Customer X",table)
  end
  return table
end

# Get Explorer Email

def get_explorer_email()
  explorer_email=search_explorer_defaults("EXP_USER_EMAIL")
  return explorer_email
end

def process_explorer_email(table)
  explorer_email=get_explorer_email()
  if $masked == 0
    table=handle_output("row","Email",explorer_email,table)
  else
    table=handle_output("row","Email","customre@company.com",table)
  end
  return table
end

# Get Explorer Phone

def get_explorer_phone()
  explorer_phone=search_explorer_defaults("EXP_PHONE")
  return explorer_phone
end

def process_explorer_phone(table)
  explorer_phone=get_explorer_phone()
  if $masked == 0
    table=handle_output("row","Phone",explorer_phone,table)
  else
    table=handle_output("row","Phone","XXX-XXXX-XXXX",table)
  end
  return table
end

# Get Explorer Country

def get_explorer_country()
  explorer_country=search_explorer_defaults("EXP_ADDRESS_COUNTRY")
  return explorer_country
end

def process_explorer_country(table)
  explorer_country=get_explorer_country()
  if $masked == 0
    table=handle_output("row","Country",explorer_country,table)
  else
    table=handle_output("row","Country","Country",table)
  end
  return table
end

# Get Explorer Modules

def get_explorer_modules()
  explorer_modules=search_explorer_defaults("EXP_WHICH")
  return explorer_modules
end

def process_explorer_modules(table)
  explorer_modules=get_explorer_modules()
  table=handle_output("row","Modules",explorer_modules,tables)
  return table
end

# Get DNS information

def get_dns_info()
  file_name="/etc/resolv.conf"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Get coreadm information

def get_coreadm_info()
  file_name="/sysconfig/coreadm.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Get install cluster

def get_install_cluster()
  file_name="/var/CLUSTER"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process install cluster

def process_install_cluster(table)
  install_cluster=get_install_cluster()
  install_cluster=install_cluster[0].split(/\=/)[1]
  table=handle_output("row","Install Cluster",install_cluster,table)
  return table
end

# Get System uptime

def get_system_uptime()
  file_name="/sysconfig/uptime.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process System uptime

def process_system_uptime(table)
  system_uptime=get_system_uptime()
  system_uptime=system_uptime[0].split(/,/)[0..1].join(" ").gsub(/\s+/,' ').gsub(/^\s+/,'')
  if $masked == 0
    table=handle_output("row","System Uptime",system_uptime,table)
  else
    table=handle_output("row","System Uptime","1 day(s)",table)
  end
  return table
end

# Process coreadm infomation

def process_coreadm_info()
  table=handle_output("title","Coreadm Configuration","","")
  coreadm_info=get_coreadm_info()
  coreadm_info.each do |line|
    (parameter,value)=line.split(": ")
    parameter=parameter.gsub(/^\s+/,'')
    table=handle_output("row",parameter,value,table)
  end
  table=handle_output("end","","",table)
  return
end

# Get dumpadm information

def get_dumpadm_info()
  file_name="/sysconfig/dumpadm.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process dumpadm infomation

def process_dumpadm_info()
  table=handle_output("title","Dumpadm Configuration","","")
  dumpadm_info=get_dumpadm_info()
  dumpadm_info.each do |line|
    (parameter,value)=line.split(": ")
    parameter=parameter.gsub(/^\s+/,'')
    if parameter.match(/directory/)
      if $masked == 0
        table=handle_output("row",parameter,value,table)
      end
    else
      table=handle_output("row",parameter,value,table)
    end
  end
  table=handle_output("end","","",table)
  return
end

# Get Domain

def get_dns_domain()
  dns_info=get_dns_info()
  dns_domain=dns_info.grep(/^domain/).join.gsub(/\n/,'').gsub(/domain /,' ').gsub(/^ /,'')
  return dns_domain
end

# Get Name Server

def get_dns_server()
  dns_info=get_dns_info()
  dns_server=dns_info.grep(/^nameserver/).join.gsub(/\n/,'').gsub(/nameserver /,' ').gsub(/^ /,'')
  return dns_server
end

# Get DNS Search

def get_dns_search()
  dns_info=get_dns_info()
  dns_search=dns_info.grep(/^search/).join.gsub(/\n/,'').gsub(/search /,' ').gsub(/^ /,'')
  return dns_search
end

# Process DNS information

def process_dns_info(table)
  dns_domain=get_dns_domain()
  dns_server=get_dns_server()
  dns_search=get_dns_search()
  if $masked == 0
    table=handle_output("row","Domain",dns_domain,table)
    table=handle_output("row","Name Server(s)",dns_server,table)
    table=handle_output("row","Search Domain(s)",dns_search,table)
  else
    table=handle_output("row","Domain","domain",table)
    table=handle_output("row","Name Server(s)","nameserver",table)
    table=handle_output("row","Search Domain(s)","search",table)
  end
  return table
end

def process_host_info()
  table=handle_output("title","Host Information","","")
  table=process_host_name(table)
  table=process_time_zone(table)
  table=process_host_id(table)
  table=process_chassis_serial(table)
  table=process_os_name(table)
  table=process_dns_info(table)
  table=process_kernel_version(table)
  table=process_arch_name(table)
  table=process_os_version(table)
  table=process_os_update(table)
  table=process_os_date(table)
  table=process_os_build(table)
  table=process_system_boot(table)
  table=process_system_uptime(table)
  table=process_install_cluster(table)
  table=handle_output("end","","",table)
end

def process_explorer_info()
  table=handle_output("title","Explorer Information","","")
  table=process_customer_name(table)
  table=process_contract_id(table)
  table=process_explorer_user(table)
  table=process_explorer_email(table)
  table=process_explorer_phone(table)
  table=process_explorer_country(table)
  table=process_dir_name(table)
  table=process_file_name(table)
  table=process_explorer_version(table)
  table=process_file_date(table)
  table=process_file_time(table)
  table=handle_output("end","","",table)
end

def process_system_info()
  table=handle_output("title","System Information","","")
  table=process_system_model(table)
  table=process_obp_version(table)
  table=process_system_memory(table)
  table=handle_output("end","","",table)
end

# Get eeprom information

def get_eeprom_info()
  file_name="/sysconfig/eeprom.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process eeprom information

def process_eeprom_info()
  table=handle_output("title","EEPROM Information","","")
  file_array=get_eeprom_info()
  file_array.each do |line|
    line.chomp
    if !line.match(/data not available/)
      (parameter,value)=line.split(/\=/)
      if parameter.match(/nvram/)
        if $masked == 0
          table=handle_output("row",parameter,value,table)
        end
      else
        table=handle_output("row",parameter,value,table)
      end
    end
  end
  table=handle_output("end","","",table)
  return
end


# Do configuration report

def config_report(report,report_type)
  if report_type.match(/all|host/)
    process_host_info()
  end
  if report_type.match(/all|eeprom/)
    process_eeprom_info()
  end
  if report_type.match(/all|os/)
    process_coreadm_info()
  end
  if report_type.match(/all|os/)
    process_dumpadm_info()
  end
  if report_type.match(/all|os/)
    process_explorer_info()
  end
  if report_type.match(/all|os/)
    process_system_info()
  end
  if report_type.match(/all|cpu/)
    process_cpu_info()
  end
  if report_type.match(/all|memory/)
    process_memory_info()
  end
  if report_type.match(/all|io|disk/)
    process_io_info()
  end
  if report_type.match(/all|kernel/)
    process_etc_system_info()
  end
  if report_type.match(/all|zones/)
    process_zones()
  end
  if report_type.match(/all|security|system|passwd|login|sendmail|inetinit|su|inetd|cront|keyserv|telnetd|power|suspend|sshd/)
    process_security(report_type)
  end
  if report_type.match(/all|security|inetd/)
    process_inetd()
  end
  if report_type.match(/all|fs/)
    process_file_systems()
  end
  if report_type.match(/all|services/)
    process_services()
  end
  if report_type.match(/all|lu/)
    process_lu_info()
  end
  if report_type.match(/all|locale/)
    process_locale_info()
  end
  if report_type.match(/all|modinfo/)
    process_mod_info()
  end
  if report_type.match(/all|package/)
    process_package_info()
  end
  if report_type.match(/all|patch/)
    process_patch_info()
  end
  if report_type.match(/all|tcp/)
    process_ip_info("tcp")
  end
  if report_type.match(/all|udp/)
    process_ip_info("udp")
  end
  puts
  return
end

# Process TCP kernel info

def get_ip_info(type)
  file_name="/netinfo/ndd/"+type+".out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

def process_ip_info(type)
  file_array=get_ip_info(type)
  if file_array
    title=type.upcase+" Kernel Information"
    row=['Paramater','Value']
    table=handle_output("title",title,row,"")
    file_array.each_with_index do |line,counter|
      if line.match(/\(/)
        parameter=line.split(/\(/)[0]
        parameter=parameter.gsub(/\s+/,'')
        value=file_array[counter+1]
        value=value.gsub(/\s+/,'')
        if value.match(/[0-9]/) and !value.match(/[A-z]/)
          row=[parameter,value]
          table=handle_output("row","",row,table)
        end
      end
    end
    table=handle_output("end","","",table)
  end
  return
end

# Process patch info

def get_patch_info()
  file_name="/patch+pkg/patch_date.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

def process_patch_info()
  file_array=get_patch_info()
  patch_date=""
  patch_number=""
  if file_array
    title="Patch Information"
    row=['Patch','Install Date']
    table=handle_output("title",title,row,"")
    file_array.each do |line|
      if line.match(/^d/)
        items=line.split(/\s+/)
        patch_number=items[-1]
        patch_date=items[-5..-2].join(" ")
        row=[patch_number,patch_date]
        table=handle_output("row","",row,table)
      end
    end
    table=handle_output("end","","",table)
  end
  return
end

# Process package info

def get_package_info()
  file_name="/patch+pkg/pkginfo-l.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

def process_package_info()
  file_array=get_package_info()
  package_name=""
  package_version=""
  package_date=""
  if file_array
    title="Package Information"
    row=['Package','Version','Install']
    table=handle_output("title",title,row,"")
    file_array.each do |line|
      (prefix,info)=line.split(/: /)
      if prefix.match(/PKGINST/)
        package_name=info
      end
      if prefix.match(/VERSION/)
        package_version=info
      end
      if prefix.match(/INSTDATE/)
        package_date=info
      end
      if prefix.match(/FILES/)
        row=[package_name,package_version,package_date]
        table=handle_output("row","",row,table)
      end
    end
    table=handle_output("end","","",table)
  end
  return
end

# Process kernel module info

def get_mod_load()
  file_name="/sysconfig/modinfo-c.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

def get_mod_info()
  file_name="/sysconfig/modinfo.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

def process_mod_info()
  file_array=get_mod_info()
  load_array=get_mod_load()
  if file_array
    title="Kernel Module Information"
    row=['Module','Information','Status']
    table=handle_output("title",title,row,"")
    file_array.each do |line|
      if !line.match(/Loadaddr/)
        mod_info=line[29..-1]
        mod_info=mod_info.split(/ \(/)
        mod_name=mod_info[0]
        if mod_info[1]
          mod_info=mod_info[1].gsub(/\)/,'')
        else
          mod_info=""
        end
        mod_status=load_array.select{|mod_status| mod_status.match(/ #{mod_name}/)}
        mod_status=mod_status[0].gsub(/^\s+/,'')
        if mod_status
          mod_status=mod_status.split(/\s+/)[3]
        else
          mod_status=""
        end
        row=[mod_name,mod_info,mod_status]
        table=handle_output("row","",row,table)
      end
    end
    table=handle_output("end","","",table)
  end
  return
end

# Process Locale info

def get_locale_info()
  file_name="/sysconfig/locale.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

def process_locale_info()
  file_array=get_locale_info()
  if file_array
    title="Locale Information"
    table=handle_output("title",title,"","")
    file_array.each do |line|
      items=line.split(/\=/)
      locale_string=items[0]
      locale_value=items[1]
      locale_value=locale_value.gsub(/"/,'')
      row=[locale_string,locale_value]
      table=handle_output("row","",row,table)
    end
    table=handle_output("end","","",table)
  end
  return
end

def get_lu_status()
  file_name="/sysconfig/lustatus.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

def get_lu_tab()
  file_name="/sysconfig/lutab"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

def get_lu_fs_info(lu_current)
  file_name="/sysconfig/lufslist_"+lu_current+".out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process Live Upgrade info

def process_lu_info()
  file_array=get_lu_status()
  lu_current=""
  if file_array
    puts
    counter=0
    title="Live Upgrade Status"
    row=['Name', 'Complete','Active Now','Active on Reboot']
    table=handle_output("title",title,row,"")
    file_array.each do |line|
      line=line.chomp
      items=line.split(/\s+/)
      lu_name=items[0]
      is_complete=items[1]
      if is_complete.match(/yes|no/)
        active_now=items[2]
        if active_now == "yes"
          lu_current=lu_name
        end
        active_on_reboot=items[3]
        if $masked == 1
          lu_name="luname#{counter}"
          counter=counter+1
        end
        row=[lu_name,is_complete,active_now,active_on_reboot]
        table=handle_output("row","",row,table)
      end
    end
    table=handle_output("end","","",table)
  end
  file_array=get_lu_tab()
  lu_name=""
  lu_boot=""
  lu_fs=""
  lu_slice=""
  if file_array
    puts
    title="Live Upgrade Disk Layout"
    row=['Name', 'ID','Filesystem','Slice/Pool','Device']
    table=handle_output("title",title,row,"")
    file_array.each do |line|
      if !line.match(/^#/)
        line=line.chomp
        items=line.split(/:/)
        lu_id=items[0]
        lu_mount=items[1]
        lu_device=items[2]
        lu_check=items[3]
        if lu_check == "1"
          lu_fs=lu_mount
          lu_slice=lu_device
        end
        if lu_check == "0"
          lu_name=lu_mount
        end
        if lu_check == "2"
          if $masked == 1 and lu_fs != "swap" and lu_mount != "/rpool"
            lu_name="luname#{lu_id}"
            if lu_fs != "zfs" and lu_fs != "vxfs"
              lu_device="/dev/dsk/disk#{lu_id}"
              lu_mount="/mount#{lu_id}"
              lu_slice="/dev/dsk/disks#{lu_id}"
            end
            if lu_fs == "zfs"
              lu_device="rpool/ROOT/luname#{lu_id}"
              lu_mount="/mount#{lu_id}"
              lu_slice="rpool/ROOT/luname#{lu_id}"
            end
            if lu_fs == "vxfs"
              lu_device="/dev/vx/dsk/luname#{lu_id}"
              lu_mount="/mount#{lu_id}"
              lu_slice="/dev/vx/dsk/lunames#{lu_id}"
            end
          end
          row=[lu_name,lu_id,lu_fs,lu_slice,lu_device]
          table=handle_output("row","",row,table)
        end
      end
    end
    table=handle_output("end","","",table)
  end
  if lu_current.match(/[A-z]/)
    file_array=get_lu_fs_info(lu_current)
    if file_array
      puts
      lu_id=0
      title="Live Upgrade Filesystem Information ("+lu_current+")"
      row=['Filesystem','Type','Mount']
      table=handle_output("title",title,row,"")
      file_array.each do |line|
        line=line.chomp
        items=line.split(/\s+/)
        lu_fs_name=items[0]
        lu_fs_type=items[1]
        lu_fs_mount=items[3]
        if lu_fs_name
          if lu_fs_name.match(/dev|pool/)
            if $masked == 1 and lu_fs_type != "swap" and lu_fs_mount != "/rpool"
              lu_name="luname#{lu_id}"
              if lu_fs_type != "zfs" and lu_fs_type != "vxfs"
                lu_fs_name="/dev/dsk/disk#{lu_id}"
                lu_fs_mount="/mount#{lu_id}"
              end
              if lu_fs_type == "zfs"
                lu_fs_name="rpool/ROOT/luname#{lu_id}"
                lu_fs_mount="/mount#{lu_id}"
              end
              if lu_fs_type == "vxfs"
                lu_fs_name="/dev/vx/dsk/disk#{lu_id}"
                lu_fs_mount="/mount#{lu_id}"
              end
              lu_id=lu_id+1
            end
            row=[lu_fs_name,lu_fs_type,lu_fs_mount]
            table=handle_output("row","",row,table)
          end
        end
      end
      table=handle_output("end","","",table)
    end
  end
  return
end

def get_manifests_services()
  file_name="/sysconfig/svcs-av.out"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process services

def process_services(s)
  file_array=get_manifests_services()
  if file_array
    puts
    title="Service"
    table=Terminal::Table.new :title => title, :headings => ['Service', 'Status','Recommeded','Complies']
    file_array.each do |line|
      items=line.split(/\s+/)
      state=items[0]
      service=items[4]
      line=$manifest_services.select{|line| line.match(/^#{service}/)}
      if service.match(/^lrc/)
        type="Legacy"
      else
        type="Manifest"
      end
      if state.match(/legacy_run|online/)
        current_value="Enabled"
      end
      if state.match(/disabled/)
        current_value="Disabled"
      end
      if state.match(/maintenance/)
        current_value="Maintenance"
      end
      if line.to_s.match(/#{service}/)
        recommended_value="Disabled"
        if current_value == recommended_value
          complies="Yes"
        else
          complies="*No*"
        end
      else
        recommended_value="N/A"
        complies="N/A"
      end
      if !service.match(/FMRI/)
        row=[service,current_value,recommended_value,complies]
        table.add_row(row)
      end
    end
  end
  puts table
  puts
  return
end

def get_vfstab()
  file_name="/etc/vfstab"
  file_array=explorer_file_to_array(file_name)
  return file_array
end

# Process file systems

def process_file_systems()
  file_name="/etc/vfstab"
  file_array=get_vfstab()
  if file_array
    puts
    counter=0
    title="File Systems ("+file_name+")"
    table=Terminal::Table.new :title => title, :headings => ['Device', 'Mount','Type']
    file_array.each do |line|
      if line.match(/^\/dev/)
        items=line.split(/\s+/)
        fs_dev=items[0]
        fs_mount=items[2]
        fs_type=items[3]
        if $masked == 1 and fs_type != "swap"
          if fs_type == "vxfs"
            fs_dev="/dev/vx/dsk/disk#{counter}"
          else
            fs_dev="/dev/dsk/disk#{counter}"
          end
          fs_mount="/mount#{counter}"
          counter=counter+1
        end
        row=[fs_dev,fs_mount,fs_type]
        table.add_row(row)
      end
    end
    puts table
    puts
  end
  return
end

# Process Security (inetd)

def process_inetd()
  file_name="/etc/inetd.conf"
  file_array=explorer_file_to_array(file_name)
  if file_array
    puts
    title="Security Settings ("+file_name+")"
    table=Terminal::Table.new :title => title, :headings => ['Service', 'Current','Recommended','Complies']
    file_array.each do |line|
      if !line.match(/^#/) and line.match(/[A-z]|[0-9]/)
        service=line.split(/\s+/)[0]
        service_check=$inetd_services.select{|service_check| service_check.match(/^#{service}/)}
        if service_check.to_s.match(/#{service}/)
          current_value="Enabled"
          recommended_value="Disabled"
          comment="*No*"
        else
          current_value="Enabled"
          recommended_value="N/A"
          comment="N/A"
        end
        row=[service,current_value,recommended_value,comment]
        table.add_row(row)
      end
    end
    puts table
    puts
  end
  return
end

# Process Security (defaults)

def process_security(report_type)
  current_name=""
  table=""
  row=""
  file_array=""
  comment=""
  $defaults.each do |item|
    found=0
    items=item.split(/,/)
    file_name=items[0]
    parameter_name=items[1]
    spacer=items[2]
    recommended_value=items[3]
    if report_type.match(/all|security/) or file_name.match(/#{report_type}/)
      if current_name != file_name
        if current_name != ""
          puts table
          puts
        end
        current_name=file_name
        title="Security Settings ("+file_name+")"
        table=Terminal::Table.new :title => title, :headings => ['Item', 'Current','Recommended','Complies']
        file_array=explorer_file_to_array(file_name)
        current_name=file_name
      end
      if file_array
        file_array.each do |line|
          line.chomp
          if line.match(/^#{parameter_name}/)
            current_value=line.split(/#{spacer}/)[1]
            if current_value
              current_value=current_value.gsub(/\s+/,'')
              found=1
              if current_value == recommended_value
                comment="Yes"
              else
                comment="*No*"
              end
              row=[parameter_name,current_value,recommended_value,comment]
              table.add_row(row)
            end
          end
        end
      end
      if found == 0
        current_value="N/A"
        comment="*No*"
        row=[parameter_name,current_value,recommended_value,comment]
        table.add_row(row)
      end
    end
    if item == $defaults.last
      puts table
      puts
    end
  end
  return
end

def clean_up()
  explorer_name=File.basename($explorer_file,".tar.gz")
  explorer_dir=$work_dir+"/"+explorer_name
  if Dir.exists?(explorer_dir)
    FileUtils.rm_rf(explorer_dir)
  end
  return
end

begin
  opt=Getopt::Std.getopts(options)
rescue
  print_usage(options)
end

# MAsk data

if opt["m"]
  $masked=1
end

if opt["a"] or opt["d"]
  $do_disks=1
end

if opt["V"]
  code_name=get_code_name()
  code_version=get_code_version()
  puts code_name+"v. "+code_version
  exit
end

if opt["v"]
  $verbose=1
  puts "Operating in verbose mode"
end

# Specify option to report on

def report_help(report,report_type)
  if report[report_type]
    puts report_type+": "+report[report_type]
  else
    puts "No option for "+report_type+" exists"
    puts
    puts "The following options exist:"
    puts
    report.each do |key, value|
      if key.length < 7
        puts key+":\t\t"+value
      else
        puts key+":\t"+value
      end
    end
    puts
  end
end

# Handle filename and hostname options

if opt["f"]
  $explorer_file=opt["f"]
  if !File.exists?($explorer_file)
    puts
    puts "Explorer File: #{$explorer_file} does not exist"
    exit
  end
else
  if !opt["s"]
    puts
    puts "Explorer file or home name not specified"
    print_usage(options)
  end
  host_name=opt["s"]
  if  !opt["b"] and !$base_dir.match(/[A-z]/)
    $base_dir=Dir.pwd
  end
  $explorer_dir=$base_dir.chomp()
  $explorer_dir=$explorer_dir+"/explorers"
  file_list=Dir.entries($explorer_dir)
  $explorer_file=file_list.grep(/tar\.gz/).grep(/#{host_name}/)
  $explorer_file=$explorer_file[0].to_s
  if !$explorer_file.match(/[A-z]/)
    puts "Explorer for "+host_name+" does not exist in "+$explorer_dir
    exit
  end
  $explorer_file=$explorer_dir+"/"+$explorer_file
end

# Set work directory

if opt["w"]
  $work_dir=opt["w"]
else
  if !$work_dir.match(/[A-z]/)
    $work_dir="/tmp"
  end
end

if opt["A"]
  report_type="all"
end

if opt["I"]
  report_type="io"
end

if opt["D"]
  report_type="disk"
  $do_disks=1
end

if opt["O"]
  report_type="os"
end

if opt["E"]
  report_type="eeprom"
end

if opt["S"]
  report_type="system"
end

if opt["Z"]
  report_type="zones"
end

if opt["K"]
  report_type="kernel"
end

if opt["M"]
  report_type="memory"
end

if opt["C"]
  report_type="cpu"
end

if opt["H"]
  report_type="host"
end

if opt["R"]
  report_type=opt["R"]
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
