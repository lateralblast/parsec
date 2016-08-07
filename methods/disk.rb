# Disk related code

# Disk paths

def get_disk_paths()
  file_name  = "/disks/mpathadm/mpathadm_list_LU.out"
  file_array = exp_file_to_array(file_name)
  disk_paths = {}
  paths      = []
  disk_name  = ""
  file_array.each do |line|
    line = line.chomp
    line = line.gsub(/^\s+/,"")
    if line.match(/dsk/)
      if disk_name
        disk_paths[disk_name] = paths
      end
      disk_name = line.split(/\//)[3].gsub(/s2/,"")
      paths = []
    else
      path_no = line.split(/: /)[1]
      paths.push(path_no)
    end
  end
  if disk_name
    disk_paths[disk_name] = paths
  end
  return disk_paths
end

# Get disk size

def get_disk_sizes()
  file_name  = "/disks/format.out"
  file_array = exp_file_to_array(file_name)
  disk_sizes = {}
  file_array.each do |line|
    line = line.chomp
    line = line.gsub(/^\s+/,"")
    if line.match(/^c/)
      (disk_name,disk_info) = line.split(/:/)
      disk_size = disk_info.split(/\s+/)[-1]
      disk_sizes[disk_name] = disk_size
    else
      if line.match(/GB|MB/) and line.match(/[0-9]\. c/)
        disk_info = line.split(/\s+/)
        if disk_info
          disk_name = disk_info[1]
          disk_size = disk_info[2..3].join.split(/\-/)[-1].gsub(/\>/,"")
          disk_sizes[disk_name] = disk_size
        end
      end
    end
  end
  return disk_sizes
end

# Get diskinfo information

def get_disk_info()
  file_name = "/disks/diskinfo"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process diskinfo insformation

def process_disk()
  file_array = get_disk_info()
  disk_paths = get_disk_paths()
  disk_sizes = get_disk_sizes()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    paths = "1,1"
    source = ""
    title  = "Disk Information"
    row    = [ 'ID', 'SSD', 'Target', 'Vendor / Product', 'Serial', 'Port', 'Path', 'Paths', 'Size' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      line = line.gsub(/^\s+/,"")
      if line.match(/^c/)
        info   = line.split(/\t/)
        disk   = info[0]
        id     = get_disk_id(disk)
        vendor = info[1]
        serial = info[2]
        port   = info[3]
        if disk
          if disk_paths.to_s.match(/[0-9]/)
            if disk_paths[disk]
              paths = disk_paths[disk][0..1].join(",")
            end
          end
          path = get_disk_path(disk)
          ssd  = get_disk_ssd_id(path)
          size = get_disk_size_from_ssd_id(ssd)
          if id
            if id.match(/cdrom/)
              id  = "na"
              ssd = "cdrom"
              size = "NA"
            end
          else
            if vendor.match(/TEAC|CDROM/)
              id   = "na"
              ssd  = "cdrom"
              size = "N/A"
            end
          end
          if !path
            path = "/dev/rdsk/"+disk
          end
          row   = [ id, ssd, disk, vendor, serial, port, path, paths, size ]
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No disk information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No disk information available\n")
    end
  end
  return table
end

# Get disk information

def get_iostat_info(disk_name)
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

def process_iostat_info(table,disk_name)
  disk_info = get_iostat_info(disk_name)
  disk_info.each do |disk_data|
    disk_data = disk_data.gsub(/\n/,'')
    disk_data = disk_data.split(/:/)
    disk_id   = disk_data[0].split(/\s+/)[2]
    if !disk_id.match(/#{disk_name}/)
      disk_id=disk_data[0].split(/\s+/)[0]
    end
    if disk_id
      table = handle_table("row","Disk",disk_id,table)
    end
    disk_vendor = disk_data[4].split(/ Product/)[0].gsub(/\s+/,'')
    if disk_vendor
      table = handle_table("row","Vendor",disk_vendor,table)
    end
    disk_model  = disk_data[5].split(/ Revision/)[0].gsub(/^\s+/,'').gsub(/\s+/,' ')
    if disk_model
      table = handle_table("row","Model",disk_model,table)
    end
    if disk_model.match(/CD|DVD/)
      disk_serial = "N/A"
    else
      disk_serial = disk_data[7].split(/ Size/)[0].gsub(/\s+/,'')
      disk_path   = get_disk_path(disk_id)
      if disk_path
        table = handle_table("row","Path",disk_path,table)
      end
    end
    disk_fw = disk_data[6].split(/ Serial/)[0].gsub(/\s+/,'')
    if disk_fw
      table = handle_table("row","Installed Firmware",disk_fw,table)
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
      table = handle_table("row","Serial",disk_serial,table)
    end
    disk_size = disk_data[8].split(/ </)[0].gsub(/\s+/,'')
    if disk_size
      table = handle_table("row","Size",disk_size,table)
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

# Get a disk ssd id

def get_disk_ssd_id(disk_path)
  file_name  = "/etc/path_to_inst"
  file_array = exp_file_to_array(file_name)
  ssd_info    = file_array.grep(/#{disk_path}\"/)[0]
  if ssd_info.to_s.match(/sd/)
    ssd_info = ssd_info.split(/\s+/)
    ssd_id   = ssd_info[2].gsub(/\"/,"")+ssd_info[1]
  else
    ssd_id = ""
  end
  return ssd_id
end

# Get disk size from ssd id

def get_disk_size_from_ssd_id(ssd_id)
  file_name  = "/disks/iostat_-E.out"
  file_array = exp_file_to_array(file_name)
  disk_size  = ""
  file_array.each_with_index do |line,index|
    if line.match(/^#{ssd_id} /)
      disk_size = file_array[index+2].split(/\s+/)[1]
      return disk_size
    end
  end
  return disk_size
end

# Handle disk sd information

def handle_disk_sd_info(table,disk_data)
  disk_data = disk_data.gsub(/\n/,'')
  disk_data = disk_data.split(/:/)
  disk_id   = disk_data[0].split(/\s+/)[2]
  if !disk_id.match(/^sd|^ssd/)
    disk_id = disk_data[0].split(/\s+/)[0]
  end
  table = handle_table("row","SD Name",disk_id,table)
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
  if disk_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    disk_path  = disk_info[0].split(/\n/)
    disk_path  = disk_path[1].gsub(/\s+/,'')
  else
    if disk_name.match(/c0t4d0/)
      file_name  = "/sysconfig/prtpicl-v.out"
      file_array = exp_file_to_array(file_name)
      disk_path  = file_array.grep(/:cdrom/)
      disk_path  = disk_path.join(" ").split(/\s+/)[2]
    end
  end
  return disk_path
end

def get_disk_id(disk_name)
  file_name  = "/disks/format.out"
  file_array = exp_file_to_array(file_name)
  disk_info  = file_array.grep(/[0-9]\./)
  disk_info  = disk_info.grep(/#{disk_name} /)
  if disk_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    disk_id = disk_info[0].split(/\./)[0].gsub(/\s+/,"")
  else
    if disk_name.match(/c0t4d0/)
      disk_id = "cdrom"
    end
  end
  return disk_id
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
      fw_line = fw_line.chomp
      if fw_line.match(/^#{disk_model}/)
        fw_line    = fw_line.split(/,/)
        avail_fw   = fw_line[1]
        avail_fw   = avail_fw.split(/\(/)[1].gsub(/\)/,'')
        readme_url = fw_line[2]
        patch_url  = fw_line[3]
        if avail_fw > disk_fw
          table = handle_table("row","Available Firmware",avail_fw,table)
          table = handle_table("row","Firmware README",readme_url,table)
          table = handle_table("row","Firmware Patch",patch_url,table)
        end
      end
    end
  end
  return table
end
