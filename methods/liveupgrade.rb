# Liveupgrade related code

def get_lu_status()
  file_name  = "/sysconfig/lustatus.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def get_lu_tab()
  file_name  = "/sysconfig/lutab"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def get_lu_fs_info(lu_current)
  file_name  = "/sysconfig/lufslist_"+lu_current+".out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process Live Upgrade info

def process_lu_info()
  file_array = get_lu_status()
  lu_current = ""
  if file_array
    puts
    counter = 0
    title   = "Live Upgrade Status"
    row     = ['Name', 'Complete','Active Now','Active on Reboot']
    table   = handle_output("title",title,row,"")
    file_array.each do |line|
      line        = line.chomp
      items       = line.split(/\s+/)
      lu_name     = items[0]
      is_complete = items[1]
      if is_complete.match(/yes|no/)
        active_now = items[2]
        if active_now == "yes"
          lu_current = lu_name
        end
        active_on_reboot = items[3]
        if $masked == 1
          lu_name = "luname#{counter}"
          counter = counter+1
        end
        row   = [lu_name,is_complete,active_now,active_on_reboot]
        table = handle_output("row","",row,table)
      end
    end
    table = handle_output("end","","",table)
  end
  file_array = get_lu_tab()
  lu_name    = ""
  lu_fs      = ""
  lu_slice   = ""
  if file_array
    puts
    title = "Live Upgrade Disk Layout"
    row   = ['Name', 'ID','Filesystem','Slice/Pool','Device']
    table = handle_output("title",title,row,"")
    file_array.each do |line|
      if !line.match(/^#/)
        line     = line.chomp
        items    = line.split(/:/)
        lu_id    = items[0]
        lu_mount = items[1]
        lu_dev   = items[2]
        lu_check = items[3]
        if lu_check == "1"
        lu_fs    = lu_mount
        lu_slice = lu_dev
        end
        if lu_check == "0"
          lu_name= lu_mount
        end
        if lu_check == "2"
          if $masked == 1 and lu_fs != "swap" and lu_mount != "/rpool"
            lu_name = "luname#{lu_id}"
            if lu_fs != "zfs" and lu_fs != "vxfs"
              lu_dev = "/dev/dsk/disk#{lu_id}"
              lu_mount = "/mount#{lu_id}"
              lu_slice = "/dev/dsk/disks#{lu_id}"
            end
            if lu_fs == "zfs"
              lu_dev   = "rpool/ROOT/luname#{lu_id}"
              lu_mount = "/mount#{lu_id}"
              lu_slice = "rpool/ROOT/luname#{lu_id}"
            end
            if lu_fs == "vxfs"
              lu_dev   = "/dev/vx/dsk/luname#{lu_id}"
              lu_mount = "/mount#{lu_id}"
              lu_slice = "/dev/vx/dsk/lunames#{lu_id}"
            end
          end
          row   = [lu_name,lu_id,lu_fs,lu_slice,lu_dev]
          table = handle_output("row","",row,table)
        end
      end
    end
    table = handle_output("end","","",table)
  end
  if lu_current.match(/[A-z]/)
    file_array = get_lu_fs_info(lu_current)
    if file_array
      puts
      lu_id = 0
      title = "Live Upgrade Filesystem Information ("+lu_current+")"
      row   = ['Filesystem','Type','Mount']
      table = handle_output("title",title,row,"")
      file_array.each do |line|
        line        = line.chomp
        items       = line.split(/\s+/)
        lu_fs_name  = items[0]
        lu_fs_type  = items[1]
        lu_fs_mount = items[3]
        if lu_fs_name
          if lu_fs_name.match(/dev|pool/)
            if $masked == 1 and lu_fs_type != "swap" and lu_fs_mount != "/rpool"
              lu_name = "luname#{lu_id}"
              if lu_fs_type != "zfs" and lu_fs_type != "vxfs"
                lu_fs_name  = "/dev/dsk/disk#{lu_id}"
                lu_fs_mount = "/mount#{lu_id}"
              end
              if lu_fs_type == "zfs"
                lu_fs_name  = "rpool/ROOT/luname#{lu_id}"
                lu_fs_mount = "/mount#{lu_id}"
              end
              if lu_fs_type == "vxfs"
                lu_fs_name  = "/dev/vx/dsk/disk#{lu_id}"
                lu_fs_mount = "/mount#{lu_id}"
              end
              lu_id = lu_id + 1
            end
            row   = [lu_fs_name,lu_fs_type,lu_fs_mount]
            table = handle_output("row","",row,table)
          end
        end
      end
      table = handle_output("end","","",table)
    end
  end
  return
end
