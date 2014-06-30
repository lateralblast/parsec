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
  if file_array
    puts
    counter = 0
    title   = "File Systems ("+file_name+")"
    table   = Terminal::Table.new :title => title, :headings => ['Device', 'Mount','Type']
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
        row = [fs_dev,fs_mount,fs_type]
        table.add_row(row)
      end
    end
    puts table
    puts
  end
  return
end

# Get file system mount point and filesystem insformation

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
        table = handle_output("row","Mount Point",mount_point,table)
        table = handle_output("row","Filesystem",file_system,table)
      else
        table = handle_output("row","Mount Point","/mount",table)
        table = handle_output("row","Filesystem",file_system,table)
      end
    end
  end
  return table
end