# Network related code

# Process TCP kernel info

def get_ip_info(type)
  file_name  = "/netinfo/ndd/"+type+".out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def process_ip_info(type)
  file_array = get_ip_info(type)
  if file_array
    title = type.upcase+" Kernel Information"
    row   = ['Paramater','Value']
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
  if aggr_info
    aggr_no = aggr_info.grep(/#{dev_name}/)
    aggr_no = aggr_no[0].to_s.split(/\s+/)
    aggr_no = aggr_no[0].to_s
    if aggr_no.match(/[0-9]/)
      aggr_name = "aggr"+aggr_no
    else
      aggr_name = ""
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
  file_name  = "/etc/aggregation.conf"
  file_array = exp_file_to_array(file_name)
  return file_array
end
