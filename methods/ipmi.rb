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

# Get IPMI SEL information

def get_ipmi_sel()
  file_name  = "/ipmi/ipmitool_sel_info.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get IPMI SEL events information

def get_ipmi_sel_events()
  file_name  = "/ipmi/ipmitool_sel_elist.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process IPMI SEL Information

def process_ipmi_sel()
  file_array = get_ipmi_sel()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "IPMI System Event Log Information"
    row   = [ 'Device / Parameter', 'Value' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if !line.match(/^SEL Information/)
        line = line.chomp
        row = line.split(/\s+:\s+/)
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No IPMI System Event Log information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No IPMI System Event Log information available\n")
    end
  end
  return table
end

# Process IPMI SEL Event Information

def process_ipmi_sel_events()
  file_array = get_ipmi_sel_events()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "IPMI System Event Log Events"
    row   = [ 'Event', 'Date', 'Time', 'Description', 'Result', 'Status' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      row = line.split(/\s+\|\s+/)
      table = handle_table("row","",row,table)
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No IPMI System Event Log event information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No IPMI System Event Log event information available\n")
    end
  end
  return table
end

# Process IPMI MC Information

def process_ipmi_mc()
  file_array = get_ipmi_mc()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "IPMI Machine Controller Information"
    row   = [ 'Device / Parameter', 'Value' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if !line.match(/Additional Device Support|Aux Firmware Rev Info/)
        if line.match(/:/)
          line = line.chomp
          row = line.split(/\s+:\s+/)
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No IPMI Machine Controller information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No IPMI Machine Controller information available\n")
    end
  end
  return table
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
      if !row[1]
        row[1] = ""
      end
      table = handle_table("row","",row,table)
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No IPMI Chassis information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No IPMI Chassis information available\n")
    end
  end
  return table
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
        if next_line
          if !next_line.match(/:/)
            row = [ ' Status', 'Not Present' ]
          else
            row = [ ' Status', 'Present' ]
          end
          table = handle_table("row","",row,table)
        end
      else
        if line.match(/:/)
          row   = line.split(/\s+:\s+/)
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No IPMI FRU information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No IPMI FRU information available\n")
    end
  end
  return table
end

# Process IPMI

def process_ipmi()
  table   = []
  t_table = process_ipmi_fru()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_ipmi_chassis()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_ipmi_mc()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_ipmi_sel()
  if t_table.class == Array
    table = table + t_table
  end
  t_tabbe = process_ipmi_sel_events()
  if t_table.class == Array
    table = table + t_table
  end
  return table
end
