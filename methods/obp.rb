# OBP related code

def process_obp_info()
  table = handle_output("title","OBP Information","","")
  table = process_sys_model(table)
  table = process_obp_ver(table)
  table = handle_output("end","","",table)
end

# Get available M series OBP version

def get_avail_obp_ver(model_name)
  avail_obp = ""
  if model_name.match(/^M[3-9]/)
    file_name = "xscf_firmware"
  else
    file_name = "system_firmware"
  end
  fw_info   = info_file_to_array(file_name)
  fw_info.each do |line|
    line.chomp
    data = line.split(/,/)
    if data[0] == model_name
      avail_obp = data[1].split(/ /)[5]
    end
  end
  return avail_obp
end

# Process OBP version.

def process_obp_ver(table)
  curr_obp   = get_obp_ver()
  curr_obp   = curr_obp.split(/ /)[1]
  model_name = $host_info["Model"].split(/ /)[-1]
  if model_name == "Server"
    model_name = $host_info["Model"].split(/ /)[-2]
  end
  avail_obp  = get_avail_obp_ver(model_name)
  latest_obp = compare_ver(curr_obp,avail_obp)
  if latest_obp == avail_obp
    avail_obp = avail_obp+" (Newer)"
  end
  table     = handle_output("row","OBP Version",curr_obp,table)
  table     = handle_output("row","Available OBP Version",avail_obp,table)
  return table
end

# Get OBP version.

def get_obp_ver()
  file_name  = "/sysconfig/prtconf-V.out"
  file_array = exp_file_to_array(file_name)
  obp_ver = file_array[0].to_s
  return obp_ver
end

