# Disk related code

# Get disk information

def get_disk_info(disk_name)
  file_name  = "/sysconfig/iostat-En.out"
  file_array = exp_file_to_array(file_name)
  disk_info  = file_array.join.split(/Analysis:/)
  if disk_name != "all"
    disk_info = disk_info.grep(/#{disk_name}/)
  end
  return disk_info
end

#  Get Disk Index Number - Used to look up sd info

def get_disk_index(disk_name)
  file_name  = "/sysconfig/iostat-En.out"
  file_array = exp_file_to_array(file_name)
  disk_info  = file_array.join.split(/Analysis:/)
  disk_info.each_with_index do |disk_data, disk_index|
    if disk_data.match(/#{disk_name} /)
      return disk_index
    end
  end
end

# Process disk information

def process_disk_info(table,disk_name)
  disk_info = get_disk_info(disk_name)
  disk_info.each do |disk_data|
    disk_data = disk_data.gsub(/\n/,'')
    disk_data = disk_data.split(/:/)
    disk_id   = disk_data[0].split(/\s+/)[2]
    if !disk_id.match(/#{disk_name}/)
      disk_id=disk_data[0].split(/\s+/)[0]
    end
    if disk_id
      table = handle_output("row","Disk",disk_id,table)
    end
    disk_vendor = disk_data[4].split(/ Product/)[0].gsub(/\s+/,'')
    if disk_vendor
      table = handle_output("row","Vendor",disk_vendor,table)
    end
    disk_model  = disk_data[5].split(/ Revision/)[0].gsub(/^\s+/,'').gsub(/\s+/,' ')
    if disk_model
      table = handle_output("row","Model",disk_model,table)
    end
    if disk_model.match(/CD|DVD/)
      disk_serial = "N/A"
    else
      disk_serial = disk_data[7].split(/ Size/)[0].gsub(/\s+/,'')
      disk_path   = get_disk_path(disk_id)
      if disk_path
        table = handle_output("row","Path",disk_path,table)
      end
    end
    disk_fw = disk_data[6].split(/ Serial/)[0].gsub(/\s+/,'')
    if disk_fw
      table = handle_output("row","Installed Firmware",disk_fw,table)
    end
    # Remove SUN* from Disk Model
    # E.g. ST914602SSUN146G -> ST914602S
    if disk_model.match(/SUN/)
      disk_model = disk_model.split(/SUN/)[0]
    end
    if !disk_fw.match(/0000/)
      table = process_avail_disk_fw(table,disk_model,disk_fw)
    end
    if disk_serial
      if $masked == 0
        table = handle_output("row","Serial",disk_serial,table)
      else
        table = handle_output("row","Serial","XXXXXXXX",table)
      end
    end
    disk_size = disk_data[8].split(/ </)[0].gsub(/\s+/,'')
    if disk_size
      table = handle_output("row","Size",disk_size,table)
    end
    disk_index = get_disk_index(disk_id)
    process_disk_sd_info(table,disk_index)
    process_disk_meta_db(table,disk_id)
    process_disk_meta_dev(table,disk_id)
    process_vfstab_info(table,disk_id)
    process_vx_disk_info(table,disk_id)
    process_vx_dev_info(table,disk_id)
  end
  return table
end

# Get Disk sd information

def get_disk_sd_info(counter)
  file_name  = "/disks/iostat-iE.out"
  file_array = exp_file_to_array(file_name)
  disk_info  = file_array.join.split(/Analysis:/)
  if counter != "all"
    disk_info = disk_info[counter]
  end
  return disk_info
end

# Handle disk sd information

def handle_disk_sd_info(table,disk_data)
  disk_data = disk_data.gsub(/\n/,'')
  disk_data = disk_data.split(/:/)
  disk_id   = disk_data[0].split(/\s+/)[2]
  if !disk_id.match(/^sd|^ssd/)
    disk_id = disk_data[0].split(/\s+/)[0]
  end
  table = handle_output("row","SD Name",disk_id,table)
  return table
end

# Process Disk sd information

def process_disk_sd_info(table,counter)
  sd_info = get_disk_sd_info(counter)
  if sd_info.is_a? Array
    sd_info.each do |disk_data|
      handle_disk_sd_info(table,disk_data)
    end
  else
    handle_disk_sd_info(table,sd_info)
  end
  return table
end

# Get disk path

def get_disk_path(disk_name)
  file_name  = "/disks/format.out"
  file_array = exp_file_to_array(file_name)
  disk_info  = file_array.grep(/[0-9]/)
  disk_info  = disk_info.join.split(/\. /)
  disk_info  = disk_info.grep(/#{disk_name} /)
  disk_info  = disk_info[0].split(/\n/)
  disk_info  = disk_info[1].gsub(/\s+/,'')
  return disk_info
end

# Get available disk firmware version

def get_avail_disk_fw(disk_model)
  file_name = "disk_firmware"
  fw_info   = info_file_to_array(file_name)
  return fw_info
end

# Process available disk firmware version

def process_avail_disk_fw(table,disk_model,disk_fw)
  fw_info = get_avail_disk_fw(disk_model)
  if fw_info
    fw_info.each do |fw_line|
      if fw_line.match(/^#{disk_model}/)
        fw_line    = fw_line.split(/,/)
        avail_fw   = fw_line[1]
        avail_fw   = avail_fw.split(/\(/)[1].gsub(/\)/,'')
        readme_url = fw_line[2]
        patch_url  = fw_line[3]
        if avail_fw > disk_fw
          table = handle_output("row","Available Firmware",avail_fw,table)
          table = handle_output("row","Firmware README",readme_url,table)
          table = handle_output("row","Firmware Patch",patch_url,table)
        end
      end
    end
  end
  return table
end
