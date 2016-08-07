# FRU related code

# Get upgradeable slot information

def get_upgrade_slot_info()
  slot_info = search_prtdiag_info("Upgradeable Slots")
  return slot_info
end

# Process slot information

def process_slots()
  slot_info = get_upgrade_slot_info()
  if slot_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "Upgradeable Slot Information"
    row   = [ 'ID', 'Status', 'Type', 'Description' ]
    table = handle_table("title",title,row,"")
    slot_info.each do |line|
      line = line.chomp
      line = line.gsub(/available PCI/,"available  PCI")
      if line.match(/^[0-9]/)
        row   = line.split(/ \s+/)
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No Upgradeable slot information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No Upgradeable slot information available\n")
    end
  end
  return table
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
      line = line.chomp
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
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No FRU information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No FRU information available\n")
    end
  end
  return table
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
    if $output_format.match(/html/)
      table = []
    else
      table = ""
    end
    labels      = ""
    status      = "NA"
    sensor_info.each_with_index do |line,index|
      line = line.chomp.gsub(/\s+$/,"")
      line = line.gsub(/\[PRESENT\]/,"")
      line = line.gsub(/\[NO_FAULT\]/,"OK")
      line = line.gsub(/\[NO_FAULT\s+\]/,"OK")
      line = line.gsub(/\[OK\s+\]/,"OK")
      if line.match(/[S,s]ensors:$|[S,s]tatus:$|[S,s]upplies:$|\):$|^LEDs:$|[S,s]peeds:$|[S,s]tate:$|[I,i]ndicators:$|Fans:$|Panel:$/) and !line.match(/System LED/)
        table = handle_table("end","","",table)
        sensor_name = line.split(/ /)[0..-2].join(" ")
        if line.match(/^LEDs:$/)
          title = "LEDs"
        else
          title = sensor_name+" Sensor Information"
        end
        if sensor_name.match(/Power/) and sys_model.match(/250|450/)
          row   = [ 'Supply', 'Rating', 'Temp', 'Status' ]
          table = handle_table("title",title,row,"")
        else
          if !sys_model.match(/V240|T200/)
            row   = [ 'Location', 'Sensor/Value', 'Status' ]
            table = handle_table("title",title,row,"")
          end
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
          if sensor_name.match(/Power/) and sys_model.match(/250|450/) and line.match(/W/)
            temp  = line.split(/\s+/)
            row   = [ temp[1], temp[2..3].join, temp[4], temp[5] ]
            table = handle_table("row","",row,table)
          end
          if sensor_name.match(/Front Status/) and line.match(/DISK\s+[0-9]/)
            temp     = line.split(/\s+/)
            location = "Front"
            row      = [ location, temp[1..2].join(" ").gsub(/:/,""), temp[3].gsub(/\[|\]/,"") ]
            table    = handle_table("row","",row,table)
            row      = [ location, temp[4..5].join(" ").gsub(/:/,""), temp[6].gsub(/\[|\]/,"") ]
            table    = handle_table("row","",row,table)
          end
          if line.match(/^SYS|^CPU|^DISK|^DBP|^UM|^AMBIENT|^PWR/)
            row = line.split(/\s+/)
            if row[2]
              if row[0].match(/CPU/) and row[1].match(/[0-9]/) and row[2].match(/[0-9]/)
                temp = [ row[0..1].join(" "), row[2], status ]
              else
                temp = [ row[0], row[1], row[2..-1].join(" ") ]
              end
              row  = temp
            else
              if row[0].match(/AMBIENT/)
                row = [ row[0], row[1], status ]
              end
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
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No sensor information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No sensor information available\n")
    end
  end
  return table
end
