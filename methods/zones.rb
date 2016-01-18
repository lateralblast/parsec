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
end

def process_zones()
  process_running_zones()
  process_configured_zones()
  return
end
