# Filesystem related code

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
    row   = [ 'Device', 'Mount', 'Type' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if line.match(/^\/dev/)
        items    = line.split(/\s+/)
        fs_dev   = items[0]
        fs_mount = items[2]
        fs_type  = items[3]
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
    if !$output_file.match(/[A-z]/)
      puts
      puts "No filesystem information available"
    end
  end
  return
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
