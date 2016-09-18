# Filesystem related code

# Get vfstab info

def get_vfstab()
  file_name  = "/etc/vfstab"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process file systems

def process_file_systems()
  file_name  = "/etc/vfstab"
  file_array = get_vfstab()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    handle_output("\n")
    counter = 0
    title   = "File Systems ("+file_name+")"
    row     = [ 'Device', 'Mount', 'Type' ]
    table   = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if line.match(/^\/dev\/|^rpool/)
        items    = line.split(/\s+/)
        fs_dev   = items[0]
        fs_mount = items[2]
        if !fs_mount.match(/\//)
          fs_mount = items[-1]
        end
        if fs_dev.match(/^rpool/)
          fs_type = "zfs"
        else
          fs_type  = items[3]
          if !fs_type.match(/[a-z]/)
            fs_type = "ufs"
          end
        end
        if $masked == 1 and fs_type != "swap"
          if fs_type == "vxfs"
            fs_dev = "/dev/vx/dsk/disk#{counter}"
          else
            fs_dev = "/dev/dsk/disk#{counter}"
          end
          fs_mount = "/mount#{counter}"
          counter  = counter+1
        end
        row   = [fs_dev,fs_mount,fs_type]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No filesystem information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No filesystem information available\n")
    end
  end
  return table
end

# Get df info

def get_vfstab()
  file_name  = "/disks/df-kl.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process df info

def process_df()
  file_name  = "/etc/vfstab"
  file_array = get_vfstab()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    t_size  = 0
    t_used  = 0
    t_avail = 0
    title   = "File System Usage"
    row     = [ 'Device', 'Size (GB)', 'Used (GB)', 'Available (GB)', 'Capacity (%)', 'Mount' ]
    table   = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^Filesystem/)
        items  = line.split(/\s+/)
        fs_dev = items[0]
        fs_tkb = items[1]
        fs_ukb = items[2]
        fs_akb = items[3]
        fs_per = items[4]
        fs_mnt = items[5]
        if !fs_tkb.match(/^0$/) and !fs_dev.match(/^\/platform/)
          fs_tgb  = (fs_tkb.to_f/1024/1024)
          fs_ugb  = (fs_ukb.to_f/1024/1024)
          fs_agb  = (fs_akb.to_f/1024/1024)
          row     = [ fs_dev, fs_tgb.round(2).to_s, fs_ugb.round(2).to_s, fs_agb.round(2).to_s, fs_per, fs_mnt ]
          table   = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No filesystem information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No filesystem information available\n")
    end
  end
  return table
end

# Process df info with totals and transfer estimates

def process_dfx()
  file_name  = "/etc/vfstab"
  file_array = get_vfstab()
  t_size  = 0
  t_used  = 0
  t_avail = 0
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title   = "File System Usage"
    row     = [ 'Device', 'Size (GB)', 'Used (GB)', 'Available (GB)', 'Capacity (%)', 'Mount' ]
    table   = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^Filesystem/)
        items  = line.split(/\s+/)
        fs_dev = items[0]
        fs_tkb = items[1]
        fs_ukb = items[2]
        fs_akb = items[3]
        fs_per = items[4]
        fs_mnt = items[5]
        if !fs_tkb.match(/^0$/) and !fs_dev.match(/^\/platform/)
          fs_tgb  = (fs_tkb.to_f/1024/1024)
          fs_ugb  = (fs_ukb.to_f/1024/1024)
          fs_agb  = (fs_akb.to_f/1024/1024)
          if !fs_dev.match(/swap/)
            t_size  = t_size.to_f+fs_tgb.to_f
            t_used  = t_used.to_f+fs_ugb.to_f
            t_avail = t_avail.to_f+fs_agb.to_f
          end
          row     = [ fs_dev, fs_tgb.round(2).to_s, fs_ugb.round(2).to_s, fs_agb.round(2).to_s, fs_per, fs_mnt ]
          table   = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("line","",row,table)
    row   = [ "Totals", t_size.to_f.round(2).to_s, t_used.to_f.round(2).to_s, t_avail.to_f.round(2).to_s, "", "" ]
    table = handle_table("row","",row,table)
    table = handle_table("line","",row,table)
    row   = [ "Transfer Time (hours)  - 100MB", "", (t_used.to_f*1.25*0.01666.to_f).round(2).to_s, "", "" , "" ]
    table = handle_table("row","",row,table)
    table = handle_table("line","",row,table)
    row   = [ "Transfer Time (hours)  - 1GB", "", (t_used.to_f*0.125*0.01666.to_f).round(2).to_s, "", "" , "" ]
    table = handle_table("row","",row,table)
    table = handle_table("line","",row,table)
    row   = [ "Transfer Time (hours)  - 10GB", "", (t_used.to_f*0.125*0.01666*0.1.to_f).round(2).to_s, "", "" , "" ]
    table = handle_table("row","",row,table)
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No filesystem information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No filesystem information available\n")
    end
  end
  return table
end

# Get file system mount point and filesystem information

def get_vfstab_info(search)
  file_name   = "/etc/vfstab"
  file_array  = exp_file_to_array(file_name)
  vfstab_info = file_array.grep(/#{search}/)
  return vfstab_info
end

def process_vfstab_info(table,search)
  vfstab_info = get_vfstab_info(search)
  vfstab_info.each do |fs_line|
    fs_line = fs_line.chomp
    if !fs_line.match(/^#/)
      fs_line     = fs_line.split(/\s+/)
      mount_point = fs_line[2]
      file_system = fs_line[3]
      if file_system.match(/swap/)
        mount_point = "/tmp"
      end
      if $masked == 0
        if mount_point
          table = handle_table("row","Mount Point",mount_point,table)
        end
        if file_system
          table = handle_table("row","Filesystem",file_system,table)
        end
      else
        table = handle_table("row","Mount Point","/mount",table)
        table = handle_table("row","Filesystem",file_system,table)
      end
    end
  end
  return table
end

def process_filesystem()
  table   = []
  t_table = process_file_systems()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_zfs_list()
  if t_table.class == Array
    table = table + t_table
  end
  return table
end
