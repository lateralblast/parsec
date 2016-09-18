# ILOM related code

# Get ILOM version

def get_ilom_ver(model_name)
  ilom_ver = ""
  if model_name.match(/^T/)
    file_name  = "/Tx000/showplatform_-v"
    file_array = exp_file_to_array(file_name)
    ilom_info  = file_array.grep(/^Version/)[0]
    if ilom_info
      ilom_info = ilom_info.split(/ /)
      ilom_ver   = ilom_info[1]
      ilom_rev   = ilom_info[2]
    end
  end
  return ilom_ver,ilom_rev
end

# Process ILOM version

def process_ilom_ver(table)
  model_name = get_model_name()
  if model_name.match(/^T/)
    (ilom_ver,ilom_rev) = get_ilom_ver(model_name)
    if ilom_ver
      table = handle_table("row","Installed ILOM Version",ilom_ver,table)
      table = handle_table("row","Installed ILOM Build",ilom_rev,table)
      if $nocheck == 0
        avail_ilom  = get_avail_ilom_ver(model_name)
        latest_ilom = compare_ver(ilom_ver,avail_ilom)
        if latest_ilom == avail_ilom
          avail_ilom = avail_ilom+" (Newer)"
        end
        table = handle_table("row","Available ILOM Version",avail_ilom,table)
      end
    end
  end
  return table
end

# Get available OBP version

def get_avail_ilom_ver(model_name)
  avail_ilom = ""
  if model_name.match(/^T[0-9]/)
    file_name = "system_firmware"
    fw_info = info_file_to_array(file_name)
    if fw_info.to_s.match(/#{model_name}/)
      line = fw_info.grep(/#{model_name}/)[0]
      data = line.split(/,/)
      if data[0] == model_name
        avail_ilom = data[1]
        if avail_ilom.match(/ILOM/)
          avail_ilom = avail_ilom.split(/ILOM /)[1].split(/\)/)[0]
        end
      end
    end
  end
  return avail_ilom
end
