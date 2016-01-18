# Zone related code

# Process the running zone information.

def process_running_zones()
  file_name  = "/sysconfig/zoneadm-list-iv.out"
  file_array = exp_file_to_array(file_name)
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "Running Zone Information"
    row   =  [ 'ID', 'Name', 'Status', 'Path', 'Brand', 'IP' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if !line.match(/STATUS/)
        line = line.gsub(/^\s+/,"")
        row  = line.split(/\s+/)
        if $masked == 1
          row[1] = "MASKED"
          row[3] = "MASKED"
        end
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No running zone information available"
  end
  return
end

# Process zone config

def process_zone_configs()
  file_name  = "/etc/zones/index"
  file_array = exp_file_to_array(file_name)
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    file_array.each do |line|
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
    puts
    puts "No configured zone information available"
  end
  return
end

# Process the configured zone information.

def process_configured_zones()
  file_name  = "/etc/zones/index"
  file_array = exp_file_to_array(file_name)
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "Configured Zone Information"
    row   =  [ 'Name', 'Status', 'Path', 'UUID' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if !line.match(/^#/)
        row  = line.split(/:/)
        if $masked == 1
          row[0] = "MASKED"
          row[2] = "MASKED"
        end
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No configured zone information available"
  end
  return
end

def process_zones()
  process_running_zones()
  process_configured_zones()
  process_zone_configs()
  return
end
