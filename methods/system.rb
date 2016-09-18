# System related code

# Get system boot time

def get_sys_boot()
  file_name  = "/sysconfig/who-b.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get system uname

def get_sys_uname()
  file_name = "/sysconfig/uname-a.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process system boot time

def process_sys_boot(table)
  boot_time = get_sys_boot()
  boot_time = boot_time[0].to_s.split(/boot/)
  boot_time = boot_time[1].to_s.gsub(/^\s+/,'').chomp
  file_date = get_extracted_file_date("/sysconfig/who-b.out")
  file_year = file_date.to_s.split(/ /)[0].split(/-/)[0].chomp
  boot_time = boot_time+" "+file_year
  if boot_time
    table = handle_table("row","Boot Time",boot_time,table)
  end
  return table
end

# Get System uptime

def get_sys_uptime()
  file_name  = "/sysconfig/uptime.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process System uptime

def process_sys_uptime(table)
  system_uptime = get_sys_uptime()
  system_uptime = system_uptime[0].split(/,/)[0..1].join(" ").gsub(/\s+/,' ').gsub(/^\s+/,'')
  if system_uptime
    table = handle_table("row","System Uptime",system_uptime,table)
  end
  return table
end

def process_hardware()
  if $output_format.match(/html|wiki/)
    table = []
  end
  table = handle_table("title","System Information","","")
  table = process_sys_model(table)
  table = process_obp_ver(table)
  table = process_ilom_ver(table)
  sys_uname = get_sys_uname()
  if !sys_uname.to_s.match(/i386/)
    table = process_ldom_ver(table)
  end
  table = process_sys_mem(table)
  table = handle_table("end","","",table)
  return table
end

# Get /etc/system info

def get_etc_sys_info()
  file_name  = "/etc/system"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process /etc/system info

def process_system()
  etc_sys_info = get_etc_sys_info()
  if etc_sys_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    etc_sys_info = etc_sys_info.grep(/^[a-z]/)
    if etc_sys_info.to_s.match(/[a-z]/)
      table = handle_table("title","Kernel Parameter Information (/etc/system)","","")
      etc_sys_info.each do |line|
        line = line.chomp
        if line.to_s.match(/^[A-z]/)
          if line.to_s.match(/[A-z]/)
            if line.to_s.match(/\=/)
              line = line.split("=")
            else
              line = line.split(":")
            end
            item_name = line[0]
            item_name = item_name.gsub(/set /,'')
            item_name = item_name.gsub(/ $/,'')
            item_val  = line[1].gsub(/^ /,'')
          end
          if item_name.to_s.match(/[A-z]/)
            if item_val
              table = handle_table("row",item_name,item_val,table)
            end
          end
        end
      end
      table = handle_table("end","","",table)
    else
      if !$output_format.match(/table/)
        table = ""
      end
      table = handle_output("\n")
      table = handle_output("No Kernel Parameter information available in /etc/system\n")
    end
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No Kernel Parameter information available in /etc/system\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No Kernel Parameter information available in /etc/system\n")
    end
  end
  return table
end
