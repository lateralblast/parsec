# EEPROM related code

# Get eeprom information

def get_eeprom_info()
  file_name  = "/sysconfig/eeprom.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process eeprom information

def process_eeprom_info()
  table      = handle_output("title","EEPROM Information","","")
  file_array = get_eeprom_info()
  file_array.each do |line|
    line.chomp
    if !line.match(/data not available/)
      (parameter,value) = line.split(/\=/)
      if parameter.match(/nvram/)
        if $masked == 0
          table = handle_output("row",parameter,value,table)
        end
      else
        table = handle_output("row",parameter,value,table)
      end
    end
  end
  table = handle_output("end","","",table)
  return
end
