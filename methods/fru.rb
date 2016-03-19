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
  fru_info  = get_fru_info()
  sys_model = get_sys_model()
  location  = ""
  if fru_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "FRU Information"
    if !sys_model.match(/V240|T200/)
      row   = [ 'Location', 'Name', 'Status' ]
      table = handle_table("title",title,row,"")
    end
    fru_info.each do |line|
      if sys_model.match(/V240|T200/)
        row = line.split(/\s+/)
        if line.match(/^Location/)
          table = handle_table("title",title,row,"")
        else
          if line.match(/^[A-Z]/) and !line.match(/:$/)
            location = row[0]
            table    = handle_table("row","",row,table)
          else
            if line.match(/[A-Z]/)
              temp    = []
              temp[0] = location
              temp    = temp + row[1..-1]
              row     = temp
              table   = handle_table("row","",row,table)
            end
          end
        end
      else
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
  sys_model   = get_sys_model()
  if sensor_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title       = ""
    row         = ""
    sensor_name = ""
    table       = ""
    labels      = ""
    sensor_info.each_with_index do |line,index|
      line = line.chomp.gsub(/\s+$/,"")
      line = line.gsub(/\[PRESENT\]/,"")
      line = line.gsub(/\[NO_FAULT\]/,"OK")
      line = line.gsub(/\[NO_FAULT\s+\]/,"OK")
      line = line.gsub(/\[OK\s+\]/,"OK")
      if line.match(/[S,s]ensors:$|[S,s]tatus:$|[S,s]upplies:$|\):$|^LEDs:$|[S,s]peeds:$|[S,s]tate:$|[I,i]ndicators:$/) and !line.match(/System LED/)
        table = handle_table("end","","",table)
        sensor_name = line.split(/ /)[0..-2].join(" ")
        if line.match(/^LEDs:$/)
          title = "LEDs"
        else
          title = sensor_name+" Sensor Information"
        end
        if !sys_model.match(/V240|T200/)
          row   = [ 'Location', 'Sensor/Value', 'Status' ]
          table = handle_table("title",title,row,"")
        end
      else
        if sys_model.match(/V240|T200/)
          if line.match(/^Location/) and !line.match(/Keyswitch/)
            row    = line.split(/\s+/)
            labels = row
            table  = handle_table("title",title,row,"")
          else
            if line.match(/^[A-Z]/) and !line.match(/Keyswitch/)
              row   = line.split(/\s+/)
              if labels.to_s.match(/Speed/)
                if row[-1].match(/rpm/)
                  temp  = row[0..-3]
                  speed = row[-2..-1].join(" ")
                  temp.push(speed)
                  row = temp
                else
                  row.push("NA")
                end
              end
              table = handle_table("row","",row,table)
            end
          end
        else
          if line.match(/^cpu/)
            if sensor_info[index+2].match(/[0-9]/)
              if line.match(/\s+/)
                loc = line.gsub(/\s+/,",")
              end
              status = "NA"
              value  = sensor_info[index+2].gsub(/^\s+|\s+$/,"").gsub(/\s+/,",")
              row    = [ loc, value, status ]
              table  = handle_table("row","",row,table)
            end
          end
          if line.match(/^SYS|^CPU|^DISK|^DBP|^UM/)
            row = line.split(/\s+/)
            if row[2]
              temp = [ row[0], row[1], row[2..-1].join(" ") ]
              row  = temp
            end
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
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No sensor information available"
  end
  return
end
