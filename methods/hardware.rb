# Hardeare related code

# Get hardware config file
# prtfiag or prtpicl

def get_hw_cfg_file()
  [ "prtdiag-v.out", "prtpicl-v.out" ].each do |file_name|
    hw_cfg_file = check_exp_file_exists(file_name)
    if hw_cfg_file == file_name
      return hw_cfg_file
    end
  end
end

# Get Architecture

def get_arch_name()
  arch_name = search_uname(4)
  return arch_name
end

def process_arch_name(table)
  arch_name = get_arch_name()
  if arch_name
    table = handle_table("row","Architecture",arch_name,table)
  end
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
  if !serial_number.match(/[0-9]/)
    file_name  = "/sysconfig/env.out"
    file_array = exp_file_to_array(file_name)
    serial_number = file_array.grep(/EXP_SERIAL/)[0].split(/\=/)[1]
  end
  return serial_number
end

# Process Model Name

def process_model_name(table)
  model_name = get_model_name()
  if model_name
    table = handle_table("row","Model",model_name,table)
  end
  return table
end

# Process chassis serial number

def process_chassis_serial(table)
  serial_number = get_chassis_serial()
  if $masked == 0
    if serial_number
      table = handle_table("row","Serial",serial_number,table)
    end
  else
    table = handle_table("row","Serial","MASKED",table)
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
      handle_table("IOU",io_unit)
      handle_table("Bus",io_type)
    end
  end
  if sys_model.match(/V440/)
  end
  return io_type
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
  if sys_model
    table = handle_table("row","Model",sys_model,table)
  end
  return table
end
