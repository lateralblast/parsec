# Disksuite related information

# Get disk metaslice

def get_disk_meta_dev(disk_name)
  file_name  = "/disks/svm/metastat-p.out"
  file_array = exp_file_to_array(file_name)
  if disk_name.match(/^c/)
    disk_info = file_array.grep(/#{disk_name}/)
  else
    disk_info = file_array.grep(/ #{disk_name} /)
  end
  return disk_info
end

# Process metaslices

def process_disk_meta_dev(table,disk_name)
  disk_info = get_disk_meta_dev(disk_name)
  disk_info.each do |disk_meta_slice|
    meta_dev_info = disk_meta_slice.split(/\s+/)
    meta_dev      = meta_dev_info[0]
    disk_slice    = meta_dev_info[-1]
    if meta_dev
      table = handle_output("row","Meta Device",meta_dev,table)
    end
    if disk_slice
      table = handle_output("row","Disk Slice",disk_slice,table)
    end
    meta_dev      = get_disk_meta_dev(meta_dev)
    meta_dev      = meta_dev.join.split(/\s+/)[0]
    process_vfstab_info(meta_dev)
  end
  return table
end

# Get disk metabdb

def get_disk_meta_db(disk_name)
  file_name  = "/disks/svm/metadb.out"
  file_array = exp_file_to_array(file_name)
  disk_info  = file_array.grep(/#{disk_name}/)
  return disk_info
end

# Process metadbs

def process_disk_meta_db(table,disk_name)
  disk_info = get_disk_meta_db(disk_name)
  disk_info.each do |disk_meta_db|
    meta_db_info  = disk_meta_db.split(/\s+/)
    meta_db_start = meta_db_info[4]
    meta_db_size  = meta_db_info[5]
    meta_db_dev   = meta_db_info[-1]
    meta_db_dev   = File.basename(meta_db_dev)
    if meta_db_dev
      table = handle_output("row","MetaDB Device",meta_db_dev,table)
    end
    if meta_db_start
      table = handle_output("row","MetaDB Start",meta_db_start,table)
    end
    if meta_db_size
      table = handle_output("row","MetaDB Size",meta_db_size,table)
    end
  end
  return table
end
