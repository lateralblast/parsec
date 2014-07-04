# QLogic HBA related code

# Get available Qlogic HBA firmware version

def get_avail_ql_fw()
  file_name = "qlogic_firmware"
  fw_info   = info_file_to_array(file_name)
  return fw_info
end

# Process available Emulex HBA firmware version

def process_avail_ql_fw(table,ql_model,ql_fw)
  table        = handle_output("row","Installed Firmware",ql_fw,table)
  fw_info      = get_avail_ql_fw()
  uc_ql_model  = ql_model.upcase
  fw_urls      = []
  if fw_info
    fw_info.each do |fw_line|
      if fw_line.match(/^#{uc_ql_model}/)
        fw_line      = fw_line.split(/,/)
        avail_fw     = fw_line[1].split(/ /)[-1]
        fw_line.each do |item|
          if item.match(/http/)
            fw_urls.push(item)
          end
        end
        latest_fw = compare_ver(ql_fw,avail_fw)
        if latest_fw == avail_fw
          avail_fw = avail_fw+" (Newer)"
          table    = handle_output("row","Available Fcode",avail_fw,table)
          if fw_urls[0]
            table = handle_output("row","Firmware Documentation",fw_urls[0],table)
          end
          if fw_urls[1]
            table = handle_output("row","Firmware Download",fw_urls[1],table)
          end
        end
      end
    end
  end
  return table
end

