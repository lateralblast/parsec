# Kernel related code

# Get driver info
# Uses path_to_inst to get driver name

def get_drv_info(io_path)
  file_name  = "/etc/path_to_inst"
  file_array = exp_file_to_array(file_name)
  return(file_array)
end

# Process driver info

def process_drv_info(io_path)
  drv_info = get_drv_info(io_path)
  if io_path == "scsi-glm"
    io_path = "glm"
  end
  if io_path.match(/qlc-pci/)
    io_path = "qlc"
  end
  if io_path.match(/emlxs/)
    io_path = io_path+"/fp@0,0"
  end
  drv_info = drv_info.grep(/"#{io_path}"/)
  drv_info = drv_info[0].split(" ")
  inst_no  = drv_info[1]
  drv_name = drv_info[2].to_s.gsub(/\"/,'')
  dev_name = drv_name+inst_no
  return dev_name,drv_name,inst_no
end

# Get kernel version

def get_kernel_ver()
  kernel_ver = search_uname(3)
  return kernel_ver
end

def get_ips_kernel_ver()
  file_name  = "/patch+pkg/pkg_listing_ips"
  file_array = exp_file_to_array(file_name)
  kernel_ver = file_array.grep(/system\/kernel\/platform/)[0].split(/ \s+/)[1]
  return kernel_ver
end

def process_kernel_ver(table)
  os_ver     = get_os_ver()
  if os_ver == "5.11"
    kernel_ver = get_ips_kernel_ver()
  else
    kernel_ver = get_kernel_ver()
  end
  table      = handle_table("row","Kernel Version",kernel_ver,table)
  return table
end

# Process kernel module info

def get_mod_load()
  file_name  = "/sysconfig/modinfo-c.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def get_mod_info()
  file_name  = "/sysconfig/modinfo.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def process_modules()
  file_array = get_mod_info()
  load_array = get_mod_load()
  if file_array
    title = "Kernel Module Information"
    row   = ['Module','Information','Status']
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if !line.match(/Loadaddr/)
        mod_info = line[29..-1]
        mod_info = mod_info.split(/ \(/)
        mod_name = mod_info[0]
        if mod_info[1]
          mod_info = mod_info[1].gsub(/\)/,'')
        else
          mod_info = ""
        end
        mod_status = load_array.select{|mod_state| mod_state.match(/ #{mod_name}/)}
        mod_status = mod_status[0].gsub(/^\s+/,'')
        if mod_status
          mod_status = mod_status.split(/\s+/)[3]
        else
          mod_status = ""
        end
        row   = [mod_name,mod_info,mod_status]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  end
  return
end

