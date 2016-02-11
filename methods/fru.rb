# FRU related code

# Get FRU information

def get_fru_info()
  fru_info = search_prtdiag_info("FRU Status")
  return fru_info
end

# Process FRU information

def process_fru()
  fru_info   = get_fru_info()
  if fru_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title      = "FRU Information"
    row        = [ 'Location', 'Name', 'Status' ]
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
  title       = ""
  row         = ""
  table       = ""
  sensor_name = ""
  counter     = 0
  if sensor_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    sensor_info.each do |line|
      if line.match(/sensors:$/)
        if counter > 1
          table = handle_table("end","","",table)
        end
        counter     = counter+1
        sensor_name = line.split(/ /)[0]
        title       = sensor_name+" Sensor Information"
        row         = [ 'Location', 'Sensor', 'Status' ]
        table       = handle_table("title",title,row,"")
      else
        if line.match(/^SYS/)
          row   = line.split(/\s+/)
          table = handle_table("row","",row,table)
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
