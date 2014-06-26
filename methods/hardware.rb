# Hardeare related code

# Get Architecture

def get_arch_name()
  arch_name = search_uname(4)
  return arch_name
end

def process_arch_name(table)
  arch_name = get_arch_name()
  table     = handle_output("row","Architecture",arch_name,table)
  return table
end

# Get the chassis serial number.

def get_chassis_serial()
  file_name  = "/sysconfig/chassis_serial.out"
  file_array = exp_file_to_array(file_name)
  if !file_array
    serial_number = ""
  else
    serial_number = file_array[0].to_s
  end
  return serial_number
end

# Process chassis serial number

def process_chassis_serial(table)
  serial_number = get_chassis_serial()
  if $masked == 0
    table = handle_output("row","Serial",serial_number,table)
  else
    table = handle_output("row","Serial","XXXXXXXX",table)
  end
  return table
end

# Handle prtdiag IO information.
# Return IO type.

def handle_prtdiag_io(line,sys_model)
  hw_info = line.split(/\s+/)
  if sys_model.match(/M5000/)
    if hw_info[0].to_s.match(/^0/)
      io_unit = hw_info[0].to_s
      io_type = hw_info[1].to_s
      handle_output("IOU",io_unit)
      handle_output("Bus",io_type)
    end
  end
  if sys_model.match(/V440/)
  end
  return io_type
end

# Get the System model

def get_sys_model()
  file_name  = "/sysconfig/prtdiag-v.out"
  file_array = exp_file_to_array(file_name)
  sys_model  = file_array.grep(/^System Configuration:/)
  sys_model  = sys_model[0]
  sys_model  = sys_model.split(": ")
  sys_model  = sys_model[1]
  sys_model  = sys_model.chomp
  sys_model  = sys_model.gsub("sun4u","")
  sys_model  = sys_model.gsub("sun4v","")
  sys_model  = sys_model.gsub(/^ /,"")
  sys_model  = sys_model.gsub(/\s+/," ")
  return sys_model
end

# Search prtdiag

def search_prtdiag_info(search_val)
  prtdiag_output = 0
  prtdiag_info   = Array.new
  file_name      = "/sysconfig/prtdiag-v.out"
  file_array     = exp_file_to_array(file_name)
  file_array.each do |line|
    if prtdiag_output == 1
      if line.match(/^=/)
        prtdiag_output = 0
      else
        prtdiag_info.push(line)
      end
    end
    if line.match(/#{search_val}/)
      prtdiag_output = 1
    end
  end
  return prtdiag_info
end

# Process System Model

def process_sys_model(table)
  sys_model = get_sys_model()
  table     = handle_output("row","Model",sys_model,table)
  return table
end
