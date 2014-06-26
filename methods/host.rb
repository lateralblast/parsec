# Host related code

def process_host_info()
  table = handle_output("title","Host Information","","")
  table = process_host_name(table)
  table = process_time_zone(table)
  table = process_host_id(table)
  table = process_chassis_serial(table)
  table = process_os_name(table)
  table = process_dns_info(table)
  table = process_kernel_ver(table)
  table = process_arch_name(table)
  table = process_os_ver(table)
  table = process_os_update(table)
  table = process_os_date(table)
  table = process_os_build(table)
  table = process_sys_boot(table)
  table = process_sys_uptime(table)
  table = process_install_cluster(table)
  table = handle_output("end","","",table)
end

# Get Sys/Host ID

def get_host_id()
  host_id = search_file_name(1).to_s
  return host_id
end

def process_host_id(table)
  host_id = get_host_id()
  if $masked == 0
    table = handle_output("row","HostID",host_id,table)
  else
    table = handle_output("row","HostID","XXXXXXXX",table)
  end
  return table
end

# Get hostname

def get_host_name()
  host_name = search_file_name(2)
  host_name = host_name.to_s.split("-")
  host_name = host_name[0].to_s
  return host_name
end

def process_host_name(table)
  host_name = get_host_name()
  if $masked == 0
    table = handle_output("row","Hostname",host_name,table)
  else
    table = handle_output("row","Hostname","explorer-host",table)
  end
  return table
end

