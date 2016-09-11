# Zone related code

# Process the running zone information.

def process_running_zones()
  file_name  = "/sysconfig/zoneadm-list-iv.out"
  file_array = exp_file_to_array(file_name)
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title  = "Running Zone Information"
    row    =  [ 'ID', 'Name', 'Status', 'Path', 'Brand', 'IP' ]
    length = 6
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      if !line.match(/STATUS/)
        line = line.gsub(/^\s+/,"")
        row  = line.split(/\s+/)
        if $masked == 1
          row[1] = "MASKED"
          row[3] = "MASKED"
        end
        if !row[5]
          row   = row.pad_right(6,"NA")
        end
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No running zone information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No running zone information available\n")
    end
  end
  return table
end

# Process zone config

def process_zone_configs()
  file_name  = "/etc/zones/index"
  file_array = exp_file_to_array(file_name)
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^#/) and line.match(/^[a-z]|^[0-9]/)
        hostname   = line.split(/:/)[0]
        zone_file  = "/etc/zones/"+hostname+".xml"
        zone_array = exp_file_to_array(zone_file)
        if zone_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
          title  = "Zone Configuration: "+hostname
          row    = [ 'Parameter', 'Value' ]
          table  = handle_table("title",title,row,"")
          length = zone_array.length
          zone_array.each_with_index do |xml_line,index|
            if !xml_line.match(/xml version|lofi/)
              xml_line = xml_line.gsub(/\<|\/\>|\<\//,"")
              xml_line = xml_line.gsub(/^\s+|\>/,"")
              if xml_line.count("=") == 1
                items = xml_line.split(/=/)
                param = items[0]
                value = items[1].gsub(/"/,"")
                if param.match(/rctl name/)
                  table = handle_table("line","","",table)
                end
                row   = [ param, value ]
                table = handle_table("row","",row,table)
              else
                if xml_line.count("=") > 1
                  pairs = xml_line.split(/" /)
                  pairs.each do |pair|
                    if !pair.match(/zone name/)
                      items = pair.split("=")
                      param = items[0]
                      value = items[1].gsub(/"/,"")
                      if param.match(/filesystem|attr name|network address/)
                        table = handle_table("line","","",table)
                      end
                      row   = [ param, value ]
                      table = handle_table("row","",row,table)
                    end
                  end
                end
              end
            end
          end
          table = handle_table("end","","",table)
        end
      end
    end
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No configured zone information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No configured zone information available\n")
    end
  end
  return table
end

# Process the configured zone information.

def process_configured_zones()
  row_length = 4
  file_name  = "/etc/zones/index"
  file_array = exp_file_to_array(file_name)
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title  = "Configured Zone Information"
    row    =  [ 'Name', 'Status', 'Path', 'UUID' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^#/)
        row  = line.split(/:/)
        if $masked == 1
          row[0] = "MASKED"
          row[2] = "MASKED"
        end
        if !row[3]
          row   = row.pad_right(4,"NA")
        end
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No configured zone information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No configured zone information available\n")
    end
  end
  return table
end

def process_zones()
  if !$output_format.match(/table|pipe/)
    table   = []
    t_table = process_running_zones()
    if t_table.class == Array
      table = table + t_table
    end
    t_table = process_configured_zones()
    if t_table.class == Array
      table = table + t_table
    end
    t_table = process_zone_configs()
    if t_table.class == Array
      table = table + t_table
    end
  else
     table = process_running_zones()
     table = process_configured_zones()
     table = process_zone_configs()
  end
  return table
end
