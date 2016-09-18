# OBP related code

def process_obp()
  table = handle_table("title","OBP Information","","")
  table = process_sys_model(table)
  table = process_obp_ver(table)
  table = handle_table("end","","",table)
  return table
end

# Get XCP version

def get_xcp_ver()
  file_name  = "/sysconfig/prtdiag-v.out"
  file_array = exp_file_to_array(file_name)
  xcp_ver    = file_array.grep(/^2[0-9][0-9][0-9]$/)[0]
  return xcp_ver
end

# Get available OBP version

def get_avail_obp_ver(model_name)
  avail_obp = ""
  if model_name.match(/^M[3-9]0/)
    file_name = "xscf_firmware"
  else
    file_name = "system_firmware"
  end
  fw_info = info_file_to_array(file_name)
  if fw_info.to_s.match(/#{model_name}/)
    line = fw_info.grep(/#{model_name}/)[0]
    data = line.split(/,/)
    if data[0] == model_name
      avail_obp = data[1]
      if avail_obp.match(/OBP/)
        avail_obp = avail_obp.split(/OBP /)[1].split(/ /)[0]
      end
      if avail_obp.match(/XCP/) and !avail_obp.match(/OBP/)
        avail_obp = avail_obp.split(/ /)[5]
      end
    end
  end
  return avail_obp
end

# Get available XCP version

def get_avail_xcp_ver(model_name)
  avail_xcp = ""
  if model_name.match(/^M[3-9]0/)
    file_name = "xscf_firmware"
  else
    file_name = "system_firmware"
  end
  fw_info   = info_file_to_array(file_name)
  if fw_info.to_s.match(/#{model_name}/)
    line = fw_info.grep(/#{model_name}/)[0]
    data = line.split(/,/)
    if data[0] == model_name
      avail_xcp = data[1]
      if avail_xcp.match(/XCP/)
        avail_xcp = avail_xcp.split(/XCP /)[1].split(/ /)[0]
      end
    end
  end
  return avail_xcp
end

# Process OBP version.

def process_obp_ver(table)
  curr_obp   = get_obp_ver()
  curr_obp   = curr_obp.split(/ /)[1]
  model_name = get_model_name()
  if model_name.match(/^M10-/)
    curr_xcp   = get_xcp_ver()
    avail_xcp  = get_avail_xcp_ver(model_name)
    latest_xcp = compare_ver(curr_xcp,avail_xcp)
    if latest_xcp == avail_xcp
      avail_xcp = avail_xcp+" (Newer)"
    end
    if curr_xcp
      table = handle_table("row","Installed XCP Version",curr_xcp,table)
    end
    if avail_xcp
      table = handle_table("row","Available XCP Version",avail_xcp,table)
    end
    if curr_obp
      table = handle_table("row","Installed OBP Version",curr_obp,table)
    end
  else
    if model_name.match(/O\.E.M\./)
      bios_ver = get_bios_ver()
      table    = handle_table("row","BIOS Version",bios_ver,table)
    else
      if $nocheck == 0
        avail_obp  = get_avail_obp_ver(model_name)
        latest_obp = compare_ver(curr_obp,avail_obp)
        if latest_obp == avail_obp
          avail_obp = avail_obp+" (Newer)"
        end
      end
      if curr_obp
        table = handle_table("row","Installed OBP/BIOS Version",curr_obp,table)
      end
      if $nocheck == 0
        if avail_obp
          if avail_obp.match(/[0-9]/)
            table = handle_table("row","Available OBP/BIOS Version",avail_obp,table)
          end
        end
      end
    end
  end
  return table
end

# Get BIOS version

def get_bios_ver()
  file_name = "/sysconfig/prtdiag-v.out"
  file_array = exp_file_to_array(file_name)
  bios_ver   = file_array.grep(/^BIOS Configuration/)[0].split(/: /)[1].chomp
  return bios_ver
end


# Get OBP version.

def get_obp_ver()
  model_name = get_model_name()
  if model_name.match(/T3/)
    file_name = "/sysconfig/prtdiag-v.out"
    file_array = exp_file_to_array(file_name)
    obp_ver    = file_array.grep(/^OBP/)[0]
    if !obp_ver
      file_name  = "/sysconfig/prtconf-vp.out"
      file_array = exp_file_to_array(file_name)
      obp_ver    = file_array.grep(/OBP/)[0].split(/\s+/)[2..3].join(" ")
    end
  else
    file_name  = "/sysconfig/prtconf-V.out"
    file_array = exp_file_to_array(file_name)
    obp_ver    = file_array[0].chomp
  end
  return obp_ver
end
