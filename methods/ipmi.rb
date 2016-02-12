# Get IPMI FRU information

def get_ipmi_fru()
  file_name  = "/ipmi/ipmitool_fru.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get IPMI chasis information

def get_ipmi_chassis()
  file_name  = "/ipmi/ipmitool_chassis_status.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get IPMI MC information

def get_ipmi_mc()
  file_name  = "/ipmi/ipmitool_mc_info.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process IPMI MC Information

def process_ipmi_mc()
  file_array = get_ipmi_chassis()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "IPMI Machine Controller Information"
    row   = [ 'Device / Parameter', 'Value' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      row = line.split(/\s+:\s+/)
      table = handle_table("row","",row,table)
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No IPMI Machine Controller information available"
  end
  return
end

# Process IPMI chassis information

def process_ipmi_chassis()
  file_array = get_ipmi_chassis()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "IPMI Chassis Information"
    row   = [ 'Device / Parameter', 'Status' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      row = line.split(/\s+:\s+/)
      table = handle_table("row","",row,table)
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No IPMI Chassis information available"
  end
  return
end

# Process IPMI FRU information

def process_ipmi_fru()
  file_array = get_ipmi_fru()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "IPMI FRU Information"
    row   = [ 'Device / Parameter', 'Value' ]
    table = handle_table("title",title,row,"")
    file_array.each_with_index do |line,index|
      line = line.chomp
      if line.match(/^FRU Device Description/)
        if index > 1
          table = handle_table("line","","",table)
        end
        row = line.split(/\s+:\s+/)
        table = handle_table("row","",row,table)
        next_line = file_array[index+1]
        if !next_line.match(/:/)
          row = [ ' Status', 'Not Present' ]
        else
          row = [ ' Status', 'Present' ]
        end
        table = handle_table("row","",row,table)
      else
        if line.match(/:/)
          row = line.split(/\s+:\s+/)
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No IPMI FRU information available"
  end
  return
end

# Process IPMI

def process_ipmi()
  process_ipmi_fru()
  process_ipmi_chassis()
  process_ipmi_mc()
  return
end
