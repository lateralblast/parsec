# Get the chassis serial number.

def get_chassis_serial()
  file_name  = "/sysconfig/chassis_serial.out"
  file_array = exp_file_to_array(file_name)
  if !file_array
    serial_number = ""
  else
    serial_number = file_array[0].to_s
    if serial_number.match(/VMware/)
      serial_number = serial_number.split(/\-/)[1].gsub(/_/,"")
    end
  end
  if !serial_number.match(/[0-9]/)
    file_name  = "/sysconfig/env.out"
    file_array = exp_file_to_array(file_name)
    serial_number = file_array.grep(/EXP_SERIAL/)[0].split(/\=/)[1]
  end
  if !serial_number.match(/[0-9]/)
    file_name  = "/sysconfig/serials"
    file_array = exp_file_to_array(file_name)
    serial_number = file_array.grep(/Explorer/)[0].split(/\|/)[2].gsub(/\s+/,"")
  end
  return serial_number
end

# Get component serials

def get_other_serials()
  file_name  = "/sysconfig/serials"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def process_other_serials()
  file_array = get_other_serials()
  if file_array.to_s.match(/[0-9]|[A-Z]|[a-z]/) and !file_array.to_s.match(/O\.E\.M\./)
    table = handle_table("title","Component Serial Information","","")
    file_array.each do |line|
      if line.match(/\|/)
        (header,component,serial,tail) = line.split(/\|/)
        component = component.gsub(/\*/,"")
        serial    = serial.gsub(/\s+/,"")
        table     = handle_table("row",component,serial,table)
      end
    end
    table = handle_table("end","","",table)
  else
    handle_output("\n")
    handle_output("No component serial number information available")
  end
  return
end

def process_serials()
  process_other_serials()
  return
end
