# Hardeare related code

# Get hardware from hostid

def get_model_from_hostid(hostid)
  case hostid
  when /^8480|^843/
    model = "M5000"
  when /^809/
    model = "M3000"
  when /^832/
    model = "480R"
  when /^83a/
    model = "V440"
  when /^83c/
    model = "V120"
  when /^84[81,9,a]/
    model = "T2000"
  when /^8[4e,58]/
    model = "T5120"
  when /^865d1/
    model = "T5-4"
  when /^865d0/
    model = "T7-4"
  when /^8622/
    model = "T4-2"
  when /^86[0,20,2a]|^84f83/
    model = "T4-1"
  when /^85[a,b]|^84f87/
    model = "T3-1"
  when /^8626/
    model = "M6-32"
  when /^864/
    model = "M7-8"
  when /^008/
    model = "x86"
  when /^00019f/
    model = "IBM System x3200 M3"
  when /^000581/
    model = "HP EliteBook Folio 9480m"
  when /^1a35/
    model = "UCSC-C22-M3S "
  else
    model = "unknown"
  end
  return model
end

# Get hardware config file
# prtfiag or prtpicl

def get_hw_cfg_file()
  found_file = ""
  [ "prtdiag-v.out", "prtpicl-v.out" ].each do |file_name|
    hw_cfg_file = check_exp_file_exists(file_name)
    if hw_cfg_file.match(/#{file_name}/)
      found_file = hw_cfg_file
      return found_file
    end
  end
  return found_file
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
