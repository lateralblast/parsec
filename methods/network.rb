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
  if file_array
    title = "VNIC Information"
    row   = [ 'Link', 'Zone', 'Over', 'Speed', 'MAC Address', 'MAC Type', 'VIDs' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if !line.match(/^LINK/)
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
  end
  return
end

# Process Link information

def process_link()
  file_array = get_ether_info()
  if file_array
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
  end
  return
end

def get_aggr_detail()
  file_name = "/netinfo/dladm/dladm_show-aggr_-x.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end  

# Process aggregate information (report)

def process_aggr()
  file_array = get_aggr_detail()
  if file_array
    title = "Aggregate Information"
    row   = [ 'Link', 'Port', 'Speed', 'Duplex', 'State', 'MAC Address', 'Port State' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line  = line.chomp
      items = line.split(/\s+/)
      if !line.match(/^LINK/)
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
          if !port.match(/net[0-9]|--/)
            port = "MASKED"
          end
        end
        row = [ name, port, speed, duplex, state, mac, pstate ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  end
  return
end

# Process network information

def process_network(type)
  file_array = get_ip_info(type)
  if file_array
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
