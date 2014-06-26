# Emulex HBA related code

# Get available Emulex HBA firmware version

def get_avail_em_fw()
  file_name = "emulex_firmware"
  fw_info   = info_file_to_array(file_name)
  return fw_info
end

# Process available Qlogic GBA firmware version

def process_avail_em_fw(table,em_model,em_fw)
  table       = handle_output("row","Installed Firmware",em_fw,table)
  fw_info     = get_avail_em_fw()
  em_model    = em_model.gsub(/-S/,'')
  uc_em_model = em_model.upcase
  em_fw       = em_fw.split(/ /)[0]
  if fw_info
    fw_info.each do |fw_line|
      if fw_line.match(/^#{uc_em_model}/)
        fw_line    = fw_line.split(/,/)
        avail_fw   = fw_line[1].split(/ /)[3]
        readme_url = fw_line[2]
        latest_fw  = compare_ver(em_fw,avail_fw)
        if latest_ver == avail_fw
          avail_fw = avail_fw+" (Newer)"
          table    = handle_output("row","Available Firmware",avail_fw,table)
          table    = handle_output("row","Firmware Download",readme_url,table)
        end
      end
    end
  end
  return table
end

