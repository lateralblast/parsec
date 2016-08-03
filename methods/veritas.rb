# Veritas related code

# Get Veritas paths

def get_vx_disk_alt_path(vx_disk_name)
  file_name    = "/disks/vxvm/vxdisk_path.out"
  file_array   = exp_file_to_array(file_name)
  vx_disk_info = file_array.grep(/#{disk_name}s2/)
  return vx_disk_info
end

# Get Veritas Enclosure Name

def get_vx_encl_name(disk_name)
  file_name  = "/disks/vxvm/vxdmpadm_listctlr_all.out"
  file_array = exp_file_to_array(file_name)
  if disk_name.match(/t/)
    disk_name = disk_name.split(/t/)[0]
  end
  vx_encl_name = file_array.grep(/^#{disk_name} /)
  vx_encl_name = vx_encl_name[0].split(/\s+/)
  vx_encl_name = vx_encl_name[3]
  return vx_encl_name
end

# Get Veritas device information

def get_vx_dev_info(disk_name)
  file_name  = "/disks/vxvm/disks/vxdisk_list=#{disk_name}s2.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process Veritas device information

def process_vx_dev_info(table,disk_name)
  vx_dev_info = get_vx_dev_info(disk_name)
  counter = 0
  vx_dev_info.each do |vx_line|
    if vx_line.match(/:/)
      vx_line = vx_line.split(/:/)
      vx_info = vx_line[1].gsub(/^\s+/,'')
      if vx_line[0].match(/^flags/)
        table = handle_table("row","Veritas Flags",vx_info,table)
      end
      if vx_line[0].match(/^pubpaths/)
        vx_paths = vx_info.split(/\s+/)
        vx_block = vx_paths[0].split(/\=/)[1]
        vx_raw   = vx_paths[1].split(/\=/)[1]
        if vx_block
          table = handle_table("row","Veritas Block Device",vx_block,table)
        end
        if vx_raw
          table = handle_table("row","Veritas Raw Device",vx_raw,table)
        end
      end
      if vx_line[0].match(/^iosize/)
        vx_iosize = vx_info.split(/\s+/)
        vx_min    = vx_iosize[0].split(/\=/)[1]+" "+vx_iosize[1]
        vx_max    = vx_iosize[2].split(/\=/)[1]+" "+vx_iosize[3]
        if vx_min
          table = handle_table("row","Veritas Minimum IO Size",vx_min,table)
        end
        if vx_max
          table = handle_table("row","Veritas Maximum IO Size",vx_max,table)
        end
      end
      if vx_line[0].match(/^guid/)
        vx_info = vx_info.gsub(/\{/,'')
        vx_info = vx_info.gsub(/\}/,'')
        if vx_info
          table = handle_table("row","Veritas GUID",vx_info,table)
        end
      end
      if vx_line[0].match(/^uuid/)
        table = handle_table("row","Veritas UUID",vx_info,table)
      end
      if vx_line[0].match(/^numpaths/)
        table = handle_table("row","Veritas Paths",vx_info,table)
        if vx_info.match(/2/)
          vx_alt_path = vx_dev_info[counter+2].split(/\s+/)[0]
          vx_alt_path = "/dev/vx/dmp/"+vx_alt_path
          if vx_alt_path
            table = handle_table("row","Veritas Alternate Path",vx_alt_path,table)
          end
        end
      end
      if vx_line[0].match(/^version/)
        table = handle_table("row","Veritas Volume Version",vx_info,table)
      end
      counter = counter+1
    end
  end
  return table
end

# Get Veritas disk information

def get_vx_disk_info(disk_name)
  file_array   = get_vx_disk_list_info()
  vx_disk_info = file_array.grep(/#{disk_name}s2/)
  if !vx_disk_info.to_s.match(/c[0-9]/)
    file_name    = "/disks/vxvm/vxdisk_path.out"
    file_array   = exp_file_to_array(file_name)
    vx_disk_info = file_array.grep(/#{disk_name}s2/)
  end
  return vx_disk_info
end

# Get Veritas disk list information

def get_vx_disk_list_info()
  file_name  = "/disks/vxvm/vxdisk-list.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process Veritas information

def process_veritas()
  file_array = get_vx_disk_list_info()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    handle_output("\n")
    title = "Veritas Disks"
    row   = ['Device', 'Configuration', 'Disk', 'Group', 'Status', 'Feature(s)', 'OS Device', 'Attribute', 'Type' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if !line.match(/DEVICE|ZFS/)
        items  = line.split(/\s+/)
        vxname = items[0]
        config = items[1]
        vxdisk = items[2]
        group  = items[3].gsub(/\(|\)/,"")
        status = items[4]
        type   = items[-1]
        if !type.match(/fc|sata|scsi/)
          type   = items[-2]
          other  = items[-3]
          osdisk = items[-4]
        else
          other  = items[-2]
          osdisk = items[-3]
        end
        feature = items[5]
        if feature.match(/^c[0-9]/)
          feature = ""
        end
        row   = [vxname, config, vxdisk, group, status, feature, osdisk, other, type]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    handle_output("\n")
    handle_output("No Veritas disk information\n")
  end
  return
end

# Process Veritas Disk information

def process_vx_disk_info(table,disk_name)
  vx_disk_info = get_vx_disk_info(disk_name)
  vx_disk_info.each do |vx_line|
    vx_line     = vx_line.split(/\s+/)
    vx_type     = vx_line[1]
    vx_disk     = vx_line[2]
    vx_group    = vx_line[3]
    vx_status   = vx_line[4]
    vx_features = vx_line[5]
    if vx_type
      if vx_type.match(/:/)
        table = handle_table("row","Veritas Type",vx_type,table)
      else
        if vx_type.match(/^c/)
          if vx_type != vx_disk
            table = handle_table("row","Veritas Type","Alternate Path for #{vx_type}",table)
          end
        end
      end
    end
    if vx_disk
      if vx_disk.match(/[A-z]/)
        table = handle_table("row","Veritas Disk Name",vx_disk,table)
      end
    end
    if vx_group
      if vx_group.match(/[A-z]/)
        vx_group = vx_group.gsub(/\(/,'').gsub(/\)/,'')
        table    = handle_table("row","Veritas Disk Group",vx_group,table)
      end
    end
    if vx_status
      table = handle_table("row","Veritas Status",vx_status,table)
    end
    if vx_features
      if !vx_features.match(/^c[0-9]/)
        table = handle_table("row","Veritas Features",vx_features,table)
      end
    end
    vx_encl_name = get_vx_encl_name(disk_name)
    if vx_encl_name
      table = handle_table("row","Veritas Enclosure",vx_encl_name,table)
    end
  end
  return table
end
