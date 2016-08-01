# Firmware related code

# Get firmware update information (available on later machines)

def get_firmware_update_info()
  file_name  = "/sysconfig/fwupdate_list_all.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get hardware revision information

def get_hardware_revision_info(search_string)
  file_array = search_prtdiag_info(search_string)
  return file_array
end

# Process hardware revision information

def process_hardware_revision_info()
  file_array = []
  temp_array = []
  [ "FW Version", "HW Revision", "System PROM revisions" ].each do |search_string|
    temp_array = get_hardware_revision_info(search_string)
    file_array = file_array+temp_array
  end
  file_array = file_array.uniq
  if file_array.to_s.match(/[0-9]|[A-Z]|[a-z]/)
    title = "Hardware Revision Information"
    row   = [ 'Hardware', 'Revision' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      line = line.gsub(/^\s+/,"")
      info = line.split(/\s+/)
      if line.match(/^Sun System Firmware/)
        row   = [ info[0..2].join(" "), info[3..-1].join(" ")]
        table = handle_table("row","",row,table)
      end
      if line.match(/^System Firmware/)
        row   = [ info[0..1].join(" "), info[2..-1].join(" ")]
        table = handle_table("row","",row,table)
      end
      if line.match(/^OBP/)
        row   = [ info[0], info[1..-1].join(" ") ]
        table = handle_table("row","",row,table)
      end
      if line.match(/^Schizo|^IOBD|^MB/)
        row   = [ info[0], info[-1] ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if !$output_file.match(/[A-z]/)
      puts
      puts "No hardware revision information"
    end
  end
  return
end

# Process Firmware update information

def process_firmware_update_info()
  file_array = get_firmware_update_info()
  table = ""
  check = 0
  if file_array.to_s.match(/[0-9]|[A-Z]|[a-z]/)
    file_array.each do |line|
      if line.match(/^SP/)
        line  = line.chomp
        title = "System SP/BIOS Firmware Information"
        row   = [ 'ID', 'Product Name', 'ILOM Version', 'BIOS/OBP Version', 'XML Support' ]
        table = handle_table("title",title,row,"")
      end
      if line.match(/^CONTROLLER/) and check == 0
        title = "Controller Firmware Information"
        row   = [ 'ID', 'Type', 'Manufacturer', 'Model', 'Product Name', 'FW Version', 'BIOS Version', 'EFI Version', 'FCODE Version', 'Package Version', 'NVDATA Version', 'XML Support' ]
        table = handle_table("title",title,row,"")
        check = 1
      end
      if line.match(/^sp/)
        row   = line.split(/ \s+/)
        table = handle_table("row","",row,table)
        table = handle_table("end","","",table)
      end
      if line.match(/^c[0-9]/)
        line  = line.split(//)
        left  = line[0..63].join.split(/ \s+/)
        left1 = left[0..3]
        left2 = left[4..-1].join(" ")
        left  = left1
        left.push(left2)
        right = line[64..-1].join.split(/ \s+/)
        if right.length < 7
          row = left + right[0..2]
          row.push("-")
          row = row + right[3..-1]
        else
          row = left + right
        end
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if !$output_file.match(/[A-z]/)
      puts
      puts "No firmware information available"
    end
  end
  return
end

# Process firmware information

def process_firmware()
  process_firmware_update_info()
  process_hardware_revision_info()
  return
end