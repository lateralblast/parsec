# OS related information

# Search uname info

def search_uname(field)
  file_name   = "/sysconfig/uname-a.out"
  file_array  = exp_file_to_array(file_name)
  uname_array = file_array[0]
  if !uname_array
    os_name = "Unknown"
  else
    uname_array = uname_array.split(" ")
    os_name     = uname_array[field]
  end
  return os_name
end

# Get OS name

def get_os_name()
  os_name = search_uname(0)
  return os_name
end

def process_os_name(table)
  os_name = get_os_name()
  if !os_name
    os_name = "Unknown"
  end
  table = handle_table("row","OS Name",os_name,table)
  return table
end

# Get  OS version

def get_os_ver()
  os_ver = search_uname(2)
  return os_ver
end

def process_os_ver(table)
  os_ver = get_os_ver()
  if !os_ver
    os_ver = "Unknown"
  end
  table = handle_table("row","OS Version",os_ver,table)
  return table
end
# Get OS build

def get_os_build()
  os_date = get_os_date()
  if os_date.match(/^11/) and os_date.match(/\./)
    os_build = os_date.split(".")[1]
  else
    os_build = search_release(3)
    if os_build.match(/\//)
      os_build = search_release(4)
    end
  end
  if !os_build
    os_build = "Unknown"
  end
  return os_build
end

def process_os_build(table)
  os_build = get_os_build()
  if !os_build
    os_build = "Unknown"
  end
  table = handle_table("row","OS Build",os_build,table)
  return table
end

# Get OS date

def get_os_date()
  os_date = search_release(2)
  return os_date
end

def process_os_date(table)
  os_date = get_os_date()
  if !os_date
    os_date = "Unknown"
  end
  table = handle_table("row","OS Release",os_date,table)
  return table
end

# Get Solaris 11 updated version from IPS package information

def get_ips_build()
  file_name  = "/patch+pkg/pkg_listing_ips"
  file_array = exp_file_to_array(file_name)
  ips_build  = file_array.grep(/system\/kernel\/platform/)[0]
  if ips_build
    ips_build = ips_build.split(/ \s+/)[1].split(/-/)[1]
  else
    ips_build = ""
  end
  return ips_build
end

# Process the OS release information.

def get_os_update()
  os_ver   = get_os_ver()
  if os_ver == "5.11"
    os_update = get_ips_build()
  else
    os_date  = get_os_date()
    os_build = get_os_build()
    if os_build.match(/_u/)
      os_update = os_build.split(/_/)[1].gsub(/[A-z]/,'')
    end
    if os_ver.match("10")
      case os_date
      when "3/05"
        os_update = "0"
      when "1/06"
        os_update = "1"
      when "6/06"
        os_update = "2"
      when "11/06"
        os_update = "3"
      when "8/07"
        os_update = "4"
      when "5/08"
        os_update = "5"
      when "10/08"
        os_update = "6"
      when "5/09"
        os_update = "7"
      when "10/09"
        os_update = "8"
      when "9/10"
        os_update = "9"
      when "8/11"
        os_update = "10"
      when "1/13"
        os_update = "11"
      end
    end
  end
  return os_update
end

def process_os_update(table)
  os_update = get_os_update()
  if !os_update
    os_update = "Unknown"
  end
  table = handle_table("row","OS Update",os_update,table)
  return table
end

# Search release info

def search_release(field)
  file_name     = "/etc/release"
  file_array    = exp_file_to_array(file_name)
  release_array = file_array[0]
  if release_array.match(/HW/)
    field = field+1
  end
  if release_array.match(/[0-9]/)
    release_array = release_array.split(" ")
    search_result = release_array[field].to_s
  else
    search_result = "Unknown"
  end
  return search_result
end
