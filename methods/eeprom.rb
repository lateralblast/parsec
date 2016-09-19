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
      line = line.chomp
      line = line.unpack("C*").pack("U*")
      if !line.match(/data not available/)
        (parameter,value) = line.split(/\=/)
        if value
          if $masked == 1 and parameter.match(/nvramrc/) and value.match(/[A-Z]|[a-z]|[0-9]/)
            value = "MASKED"
          else
            value = value.strip_control_characters
          end
          table = handle_table("row",parameter,value,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No EEPROM information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No EEPROM information available\n")
    end
  end
  return table
end
