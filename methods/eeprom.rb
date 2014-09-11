# EEPROM related code

# Get eeprom information

def get_eeprom_info()
  file_name  = "/sysconfig/eeprom.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process eeprom information

def process_eeprom()
  table      = handle_table("title","EEPROM Information","","")
  file_array = get_eeprom_info()
  file_array.each do |line|
    line.chomp
    if !line.match(/data not available/)
      (parameter,value) = line.split(/\=/)
      if value
        table = handle_table("row",parameter,value,table)
      end
    end
  end
  table = handle_table("end","","",table)
  return
end
