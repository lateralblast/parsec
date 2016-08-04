# Get ZFS filesystem list

def get_zfs_list()
  file_name  = "/disks/zfs/zfs_list.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get ZFS pool list

def get_zpool_list()
  file_name  = "/disks/zfs/zpool_list.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get ZFS snapshot list

def get_zfs_snapshots()
  file_name  = "/disks/zfs/zfs_list-t_snapshot.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get ZFS volumes

def get_zfs_volumes()
  file_name = "/disks/zfs/zfs_list-t_volume.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process ZFS

def process_zfs()
  os_ver = get_os_version()
  if !os_ver.match(/10|11/)
    handle_output("\n")
    handle_output("No ZFS information available\n")
  end
  table   = []
  t_table = process_zfs_list()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_zpool_list()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_zfs_volumes()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_zfs_snapshots()
  if t_table.class == Array
    table = table + t_table
  end
  return table
end

# Proces ZFS volumes

def process_zfs_volumes()
  file_array = get_zfs_volumes()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/) and !file_array.to_s.match(/no pools available|no datasets available/)
    title = "ZFS Volumes"
    row   = [ 'Name', 'Used', 'Avail', 'Refer', 'Mount' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^NAME/)
        items = line.split(/\s+/)
        name  = items[0]
        used  = items[1]
        avail = items[2]
        refer = items[3]
        if $masked == 1
          mount = "MASKED"
        else
          mount = items[4]
        end
        row   = [ name, used, avail, refer, mount ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if !$output_format.match(/table/)
      table = ""
    end
    handle_output("\n")
    handle_output("No ZFS volume information available\n")
  end
  return table
end

# Process ZFS list

def process_zfs_list()
  file_array = get_zfs_list()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/) and !file_array.to_s.match(/no pools available|no datasets available/)
    title = "ZFS Filesystems"
    row   = [ 'Name', 'Used', 'Avail', 'Refer', 'Mount' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^NAME/)
        items = line.split(/\s+/)
        name  = items[0]
        used  = items[1]
        avail = items[2]
        refer = items[3]
        if $masked == 1
          mount = "MASKED"
        else
          mount = items[4]
        end
        row   = [ name, used, avail, refer, mount ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if !$output_format.match(/table/)
      table = ""
    end
    handle_output("\n")
    handle_output("No ZFS filesystem information available\n")
  end
  return table
end

# Process ZFS list

def process_zfs_snapshots()
  file_array = get_zfs_snapshots()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/) and !file_array.to_s.match(/no pools available|no datasets available/)
    title = "ZFS Snapshots"
    row   = [ 'Name', 'Used', 'Avail', 'Refer', 'Mount' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^NAME/)
        items = line.split(/\s+/)
        if $masked == 1
          name = "MASKED"
        else
          name = items[0]
        end
        used  = items[1]
        avail = items[2]
        refer = items[3]
        if $masked == 1
          mount = "MASKED"
        else
          mount = items[4]
        end
        row   = [ name, used, avail, refer, mount ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if !$output_format.match(/table/)
      table = ""
    end
    handle_output("\n")
    handle_output("No ZFS snapshot information available\n")
  end
  return table
end

# Process ZFS pool list

def process_zpool_list()
  file_array = get_zpool_list()
  table = ""
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/) and !file_array.to_s.match(/no pools available|no datasets available/)
      file_array.each do |line|
      line  = line.chomp.gsub(/\s+$/,"")
      items = line.split(/\s+/)
      if !line.match(/^NAME/)
        items  = line.split(/\s+/)
        if $masked == 1
          items[0] = "MASKED"
        end
        table  = handle_table("row","",items,table)
      else
        title = "ZFS Pools"
        table = handle_table("title",title,items,"")
      end
    end
    table = handle_table("end","","",table)
  else
    if !$output_format.match(/table/)
      table = ""
    end
    handle_output("\n")
    handle_output("No ZFS pool information available\n")
  end
  return table
end
