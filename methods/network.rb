# Network related code

# Process TCP kernel info

def get_ip_info(type)
  file_name  = "/netinfo/ndd/"+type+".out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get network physical device info

def get_phys_info()
  file_name = "/netinfo/dladm/dladm_show-phys_-L.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# get link name for Solaris 11

def get_link_name(dev_name)
  file_array = get_phys_info()
  if file_array
    file_array.each do |line|
      items = line.split(/\s+/)
      if dev_name == items[1]
        return items[0]
      end
    end
  end
  return link_name
end

# Get ether information

def get_ether_info()
  file_name = "/netinfo/dladm/dladm_show-ether_-Z.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get Link details

def get_link_details(link_name)
  file_array = get_ether_info()
  if file_array
    file_array.each do |line|
      items = line.split(/\s+/)
      if items[0] == link_name
        return items[3],items[4],items[5]
      end
    end
  end
  return link_state,link_auto,link_speed
end

# Get VNIC info

def get_vnic_info()
  file_name = "/netinfo/dladm/dladm_show-vnic_-Z.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process VNIC info

def process_vnic()
  file_array = get_vnic_info()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    file_array.each do |line|
      if line.match(/^LINK/)
        title = "VNIC Information"
        row   = [ 'Link', 'Zone', 'Over', 'Speed', 'MAC Address', 'MAC Type', 'VIDs' ]
        table = handle_table("title",title,row,"")
      else
        items = line.split(/\s+/)
        link  = items[0]
        zone  = items[1]
        over  = items[2]
        speed = items[3]
        mac   = items[4]
        type  = items[5]
        vids  = items[6]
        if $masked == 1
          link = "MASKED"
          if !zone.match(/global/)
            zone = "MASKED"
          end
          if !over.match(/net[0-9]/)
            over = "MASKED"
          end
          mac = "MASKED"
        end
        row = [ link, zone, over, speed, mac, type, vids ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No VNIC information available"
  end
  return
end

# Get Link slots

def get_link_slots()
  file_name = "/netinfo/dladm/dladm_show-phys_-L.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process Link speed information

def process_link_slots()
  file_array = get_link_slots()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    file_array.each do |line|
      if line.match(/^LINK/)
        title = "Link Slot Information"
        row   = [ 'Link', 'Device', 'Slot' ]
        table = handle_table("title",title,row,"")
      else
        items = line.split(/\s+/)
        link  = items[0]
        dev   = items[1]
        loc   = items[2]
        if $masked == 1
          if !link.match(/net[0-9]/)
            over = "MASKED"
          end
        end
        row = [ link, dev, loc ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No link slot information available"
  end
  return
end

# Process Link physical information

def process_link_speed()
  file_array = get_ether_info()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "Link Information"
    row   = [ 'Link', 'Zone', 'Type', 'State', 'Auto', 'Speed', 'Pause' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if !line.match(/^LINK/)
        items = line.split(/\s+/)
        link  = items[0]
        zone  = items[1]
        type  = items[2]
        state = items[3]
        auto  = items[4]
        speed = items[5]
        pause = items[6]
        if $masked == 1
          if !link.match(/net[0-9]/)
            over = "MASKED"
          end
        end
        row = [ link, zone, type, state, auto, speed, pause ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No link information available"
  end
  return
end

# Process Link information

def process_link()
  process_link_speed()
  process_link_slots()
  return
end

# Get Aggregate details

def get_aggr_detail()
  file_name = "/netinfo/dladm/dladm_show-aggr_-x.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end  

# Get Aggregate config

def get_aggr_config()
  file_name = "/netinfo/dladm/dladm_show-aggr_-Z.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end  

# Process aggregate information (report)

def process_aggr()
  process_aggr_detail()
  process_aggr_config()
  return
end

# Process Aggregate config

def process_aggr_config()
  file_array = get_aggr_config()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    file_array.each do |line|
      line  = line.chomp
      items = line.split(/\s+/)
      if line.match(/^LINK/)
        title = "Aggregate Configuration"
        row   = [ 'Link', 'Zone', 'Mode', 'Policy', 'Address Policy', 'LACP Activity', 'LACP Timer', 'Flags' ]
        table = handle_table("title",title,row,"")
      else
        name   = items[0]
        zone   = items[1]
        mode   = items[2]
        policy = items[3]
        addr   = items[4]
        lacp   = items[5]
        timer  = items[6]
        flags  = items[7]
        if $masked == 1
          name = "MASKED"
        end
        row = [ name, zone, mode, policy, addr, lacp, timer, flags ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No aggregate configuration information available"
  end
  return
end

# Process Aggregate detail

def process_aggr_detail()
  file_array = get_aggr_detail()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    file_array.each do |line|
      line  = line.chomp
      items = line.split(/\s+/)
      if line.match(/^LINK/)
        title = "Aggregate Detailed Information"
        row   = [ 'Link', 'Port', 'Speed', 'Duplex', 'State', 'MAC Address', 'Port State' ]
        table = handle_table("title",title,row,"")
      else
        if line.match(/--/)
          name   = items[0]
          port   = "--"
          speed  = items[2]
          duplex = items[3]
          state  = items[4]
          mac    = items[5]
          pstate = items[6]
        else
          name   = "--"
          port   = items[1]
          speed  = items[2]
          duplex = items[3]
          state  = items[4]
          mac    = items[5]
          pstate = items[6]
        end
        if $masked == 1
          name = "MASKED"
          mac  = "MASKED"
          if !port.match(/net[0-9]|--/)
            port = "MASKED"
          end
        end
        row = [ name, port, speed, duplex, state, mac, pstate ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No aggregate detailed information available"
  end
  return
end

# Process ndd info for network interface

def process_ndd_nic_driver(nic_name)
  nic_no  = nic_name.gsub(/[a-z]/,"")
  driver  = nic_name.gsub(/[0-9]/,"")
  nic_dir = driver+"."+nic_no
  file_name  = "/netinfo/ndd/"+nic_dir+"/list.out"
  file_array = exp_file_to_array(file_name)
  if file_array.to_s.match(/[A-Z]|[a-z][0-9]/)
    puts
    title = "Kernel "+nic_name+" Paramater Information"
    row   = ['Parameter', 'Type', 'Value']
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if line.match(/^[a-z]/) and !line.match(/^\?/)
        line  = line.chop
        param = line.split(/\(/)[0].gsub(/\s+/,"")
        type  = line.split(/\(/)[1].split(/\)/)[0]
        value_name  = "/netinfo/ndd/"+nic_dir+"/"+param+".out"
        value_array = exp_file_to_array(value_name)
        if value_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
          value = value_array[0].chop
        else
          value = ""
        end
        row   = [ param, type, value ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  end
  return
end

# Process network interface information

def process_nic_info()
  file_name  = "/etc/path_to_inst"
  file_array = exp_file_to_array(file_name)
  nic_list   = []
  if file_array.to_s.match(/[A-Z]|[a-z][0-9]/)
    title = "Network Interfaces"
    row   = [ 'Interface', 'Path', 'hostname', 'IP' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if line.match(/network/)
        line = line.gsub(/"/,"")
        (path,inst,driver) = line.split(/\s+/)
        nic_name = driver+inst
        nic_list.push(nic_name)
        nic_host = get_if_hostname(nic_name)
        nic_ip   = get_hostname_ip(nic_host)
        row      = [ nic_name, path, nic_host, nic_ip ]
        table    = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
    nic_list = nic_list.uniq
    nic_list.each do |nic_name|
      process_ndd_nic_driver(nic_name)
    end
  else
    puts
    puts "No network interface information available"
  end
  return
end

# Process network information

def process_network(type)
  file_array = get_ip_info(type)
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = type.upcase+" Kernel Information"
    row   = [ 'Paramater', 'Value' ]
    table = handle_table("title",title,row,"")
    file_array.each_with_index do |line,counter|
      if line.match(/\(/)
        param = line.split(/\(/)[0]
        param = param.gsub(/\s+/,'')
        value = file_array[counter+1]
        value = value.gsub(/\s+/,'')
        if value.match(/[0-9]/) and !value.match(/[A-z]/)
          row   = [param,value]
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No "+type.upcase+" kernel information available"
  end
  return
end

# Process aggregate information

def process_aggr_info(dev_name)
  aggr_name = ""
  aggr_info = get_aggr_info()
  os_ver    = get_os_version()
  if aggr_info
    if os_ver.match(/11/)
      aggr_info.each do |line|
        items = line.split(/\s+/)
        if items[1] == "aggr"
          over = items[4..-1].join(" ")
          if over.match(/#{dev_name}/)
            return items[0]
          end
        end
      end
    else
      aggr_no = aggr_info.grep(/#{dev_name}/)
      aggr_no = aggr_no[0].to_s.split(/\s+/)
      aggr_no = aggr_no[0].to_s
      if aggr_no.match(/[0-9]/)
        aggr_name = "aggr"+aggr_no
      else
        aggr_name = ""
      end
    end
  end
  return aggr_name
end

# Get interface hostname

def get_if_hostname_info(if_name)
  file_name  = "/etc/hostname."+if_name
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process interface hostname

def get_if_hostname(if_name)
  if_hostname = get_if_hostname_info(if_name)
  if if_hostname.to_s.match(/[A-z]/)
    if if_hostname.grep(/failover/)
      if_hostname = if_hostname.join.split(/ /)[0].to_s
    end
  else
    if_hostname = ""
  end
  return if_hostname
end

# Get ip from hostname

def get_hostname_ip(hostname)
  hostname_ip = ""
  file_name   = "/etc/inet/hosts"
  file_array  = exp_file_to_array(file_name)
  hostname_ip = file_array.grep(/#{hostname}/)
  hostname_ip = hostname_ip[0].to_s.split(/\s+/)[0]
  return hostname_ip
end

# Get aggregate information

def get_aggr_info()
  os_ver = get_os_version()
  if os_ver.match(/11/)
    file_name  = "/netinfo/dladm/dladm.out"
  else
    file_name  = "/etc/aggregation.conf"
  end
  file_array = exp_file_to_array(file_name)
  return file_array
end
