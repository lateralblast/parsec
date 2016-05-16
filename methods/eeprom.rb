# EEPROM related code

# Get eeprom information

def get_eeprom_info()
  file_name  = "/sysconfig/eeprom.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process eeprom information

def process_eeprom()
  file_array = get_eeprom_info()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    table = handle_table("title","EEPROM Information","","")
    file_array.each do |line|
      line.chomp
      if !line.match(/data not available/)
        (parameter,value) = line.split(/\=/)
        if value
          value = value.remove_non_ascii
          value = value.strip_control_characters
          table = handle_table("row",parameter,value,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No EEPROM information available"
  end
  return
end
