# Kernel related code

# Get information from /etc/path_to_inst

def get_path_to_inst()
  file_name  = "/etc/path_to_inst"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Search /etc/path_to_inst

def search_path_to_inst(io_path,dev_id,drv_name)
  actual_path = ""
  actual_id   = ""
  actual_name = ""
  temp_path   = ""
  temp_id     = ""
  temp_name   = ""
  file_array  = get_path_to_inst()
  file_array.each do |line|
    line = line.chomp
    if line.match(/^"/)
      info      = line.split(/\s+/)
      temp_path = info[0].gsub(/"/,"")
      temp_id   = info[1]
      temp_name = info[2].gsub(/"/,"")
      if temp_path.match(/#{io_path}/) or !io_path.match(/[a-z]/)
        if temp_id.match(/#{dev_id}/) or !dev_id.match(/[0-9]/)
          if temp_name.match(/#{drv_name}/) or !drv_name.match(/[a-z]/)
            actual_path = temp_path
            actual_id   = temp_id
            actual_name = temp_name
            return actual_path,actual_id,actual_name
          end
        end
      end
    end
  end
  return actual_path,actual_id,actual_name
end

# Get driver info
# Uses path_to_inst to get driver name

def get_drv_info(io_path)
  file_name  = "/etc/path_to_inst"
  file_array = exp_file_to_array(file_name)
  return file_array
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
  if file_array.to_s.match(/[A-Z]|[a-z]/)
    kernel_ver = file_array.grep(/system\/kernel\/platform/)[0].split(/ \s+/)[1]
  end
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

# Get ndd tcp info

def get_ndd_tcp_info()
  ndd_type   = "ndd"
  file_array = get_ndd_info(ndd_type)
  return file_array
end

# Get ndd arp info

def get_ndd_arp_info()
  ndd_type   = "arp"
  file_array = get_ndd_info(ndd_type)
  return file_array
end

# Generic routine for getting ndd information

def get_ndd_info(ndd_type)
  file_name  = "/netinfo/ndd/"+ndd_type+".out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process ndd tcp information

def process_tcp()
  table    = []
  ndd_type = "tcp"
  t_table = process_network_info(ndd_type)
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_ndd_info(ndd_type)
  if t_table.class == Array
    table = table + t_table
  end
  return table
end

# Process ndd arp information

def process_arp()
  ndd_type = "arp"
  table = process_ndd_info(ndd_type)
  return table
end

# Process ndd icmp information

def process_icmp()
  ndd_type = "icmp"
  table = process_ndd_info(ndd_type)
  return table
end

# Process ndd stcp information

def process_sctp()
  ndd_type = "sctp"
  table = process_ndd_info(ndd_type)
  return table
end

# Process ndd udp information

def process_udp()
  table    = []
  ndd_type = "udp"
  t_table = process_network_info(ndd_type)
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_ndd_info(ndd_type)
  if t_table.class == Array
    table = table + t_table
  end
  return table
end


# Process ndd ip information

def process_ip()
  table    = []
  ndd_type = "ip"
  t_table  = process_network_info(ndd_type)
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_ndd_info(ndd_type)
  if t_table.class == Array
    table = table + t_table
  end
  return table
end

# Generic routine for processing ndd information

def process_ndd_info(ndd_type)
  file_array = get_ndd_info(ndd_type)
  if ndd_type.match(/[a-z]/)
    if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
      title = "Kernel "+ndd_type.upcase+" Parameter Information"
      row   = ['Parameter', 'Type', 'Value']
      table = handle_table("title",title,row,"")
      file_array.each_with_index do |line,index|
        line = line.chomp
        if line.match(/^#{ndd_type}/) and !line.match(/status|hash|obsolete|host_param/)
          (param,type) = line.split(/\(/)
          param = param.gsub(/\s+/,"")
          type  = type.split(/\)/)[0]
          value = ""
          count = index+1
          if line.match(/tcp_extra_priv_ports/)
            while !file_array[count].match(/^tcp/)
              if !value.match(/[A-Z]|[a-z]|[0-9]/)
                value = file_array[count].chop.gsub(/\s+$/,"")
              else
                value = value+" "+file_array[count].chop.gsub(/\s+/,"")
              end
              count = count+1
            end
          else
            value = file_array[count]
          end
          if value.match(/^#{ndd_type}/)
            row   = [ param, type, "" ]
            (param,type) = value.split(/\(/)
            param = param.gsub(/\s+/,"")
            type  = type.split(/\)/)[0]
            row   = [ param, type, "" ]
          else
            value = value.chomp
            row   = [ param, type, value ]
            table = handle_table("row","",row,table)
          end
        end
      end
      table = handle_table("end","","",table)
    else
      if !$output_format.match(/table/)
        table = ""
      end
      table = handle_output("\n")
      table = handle_output("No #{ndd_type.upcase} information available\n")
    end
  end
  return table
end

# Get module information

def get_mod_info()
  file_name  = "/sysconfig/modinfo.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process module information

def process_modules()
  file_array = get_mod_info()
  load_array = get_mod_load()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "Kernel Module Information"
    row   = ['Module','Information','Status']
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/Loadaddr/)
        mod_name = line[29..-1]
        mod_name = mod_name.split(/ \(/)[0]
        if mod_name.to_s.match(/\-/)
          mod_name = line.split(/\s+/)[6]
        end
        if mod_name.match(/^\(/)
          mod_name = line.split(/\s+/)[5]
        end
        if line.match(/\(/)
          mod_info = line.split(/\(/)[1].split(/\)/)[0]
        else
          mod_info = mod_name
        end
        mod_status = load_array.select{|mod_state| mod_state.match(/ #{mod_name}/)}
        if mod_status.to_s.match(/[0-9]|[A-Z]|[a-z]/)
          mod_status = mod_status[0].gsub(/^\s+/,'')
          if mod_status
            mod_status = mod_status.split(/\s+/)[3]
          else
            mod_status = ""
          end
        else
          mod_status = ""
        end
        row   = [mod_name,mod_info,mod_status]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No kernel module information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No kernel module information available\n")
    end
  end
  return table
end
