# FRU related code

# Get upgradeable slot information

def get_upgrade_slot_info()
  slot_info = search_prtdiag_info("Upgradeable Slots")
  return slot_info
end

# Process slot information

def process_upgrade_slots()
  slot_info = get_upgrade_slot_info()
  if slot_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "Upgradeable Slot Information"
    row   = [ 'ID', 'Status', 'Type', 'Description' ]
    table = handle_table("title",title,row,"")
    slot_info.each do |line|
      if line.match(/^[0-9]/)
        row   = line.split(/ \s+/)
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No Upgradeable slot information available"
  end
  return
end

# Get FRU information

def get_fru_info()
  fru_info = search_prtdiag_info("FRU Status")
  return fru_info
end

# Process FRU information

def process_fru()
  fru_info = get_fru_info()
  if fru_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "FRU Information"
    row   = [ 'Location', 'Name', 'Status' ]
    table = handle_table("title",title,row,"")
    fru_info.each do |line|
      if line.match(/^SYS/)
        line  = line.gsub(/Not present/,"not-present")
        row   = line.split(/\s+/)
        table = handle_table("row","",row,table)
      else
        if line.match(/SYS/)
          line = line.gsub(/^\s+/,"")
          location = "MB"
          (name,status) = line.split(/\s+/)
          row = [ location, name, status ]
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No FRU information available"
  end
  return
end

# Get environmental Information

def get_sensor_info()
  sensor_info = search_prtdiag_info("Environmental Status")
  return sensor_info
end

# Process environmental information

def process_sensors()
  sensor_info = get_sensor_info()
  if sensor_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title       = ""
    row         = ""
    sensor_name = ""
    table       = ""
    sensor_info.each do |line|
      line = line.chomp
      line = line.gsub(/\[NO_FAULT\]/,"OK")
      line = line.gsub(/\[NO_FAULT\s+\]/,"OK")
      if line.match(/[S,s]ensors:$|[S,s]tatus:$|[S,s]upplies:$|\):$/) and !line.match(/System LED/)
        table = handle_table("end","","",table)
        sensor_name = line.split(/ /)[0]
        title       = sensor_name+" Sensor Information"
        row         = [ 'Location', 'Sensor/Value', 'Status' ]
        table       = handle_table("title",title,row,"")
      else
        if line.match(/^SYS|^CPU|^DISK|^DBP/)
          row   = line.split(/\s+/)
          table = handle_table("row","",row,table)
        end 
        if line.match(/^FAN|^PS/)
          values = line.split(/\s+/)
          if values[1].match(/FAN/)
            row = [ values[0..1].join(" "), values[2], values[3]]
          else
            row = [ values[0], values[1], values[2]]
          end
          table  = handle_table("row","",row,table)
        end 
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No sensor information available"
  end
  return
end
