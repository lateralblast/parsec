# OS related information

# Search uname info

def search_uname(field)
  file_name   = "/sysconfig/uname-a.out"
  file_array  = exp_file_to_array(file_name)
  uname_array = file_array[0]
  uname_array = uname_array.split(" ")
  os_name     = uname_array[field]
  return os_name
end

# Get OS name

def get_os_name()
  os_name = search_uname(0)
  return os_name
end

def process_os_name(table)
  os_name = get_os_name()
  if os_name
    table = handle_table("row","OS Name",os_name,table)
  end
  return table
end

# Get  OS version

def get_os_ver()
  os_ver = search_uname(2)
  return os_ver
end

def process_os_ver(table)
  os_ver = get_os_ver()
  if os_ver
    table = handle_table("row","OS Version",os_ver,table)
  end
  return table
end
# Get OS build

def get_os_build()
  os_date = get_os_date()
  if os_date.match(/^11/) and !os_date.match(/\//)
    os_build = os_date.split(".")[1]
  else
    os_build = search_release(3)
    if os_build.match(/\//)
      os_build = search_release(4)
    end
  end
  return os_build
end

def process_os_build(table)
  os_build = get_os_build()
  if os_build
    table = handle_table("row","OS Build",os_build,table)
  end
  return table
end

# Get OS date

def get_os_date()
  os_date = search_release(2)
  return os_date
end

def process_os_date(table)
  os_date = get_os_date()
  if os_date
    table = handle_table("row","OS Release",os_date,table)
  end
  return table
end

# Get Solaris 11 updated version from IPS package information

def get_ips_build()
  file_name  = "/patch+pkg/pkg_listing_ips"
  file_array = exp_file_to_array(file_name)
  ips_build  = file_array.grep(/system\/kernel\/platform/)[0].split(/ \s+/)[1].split(/-/)[1]
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
  if os_update
    table = handle_table("row","OS Update",os_update,table)
  end
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
  release_array = release_array.split(" ")
  search_result = release_array[field].to_s
  return search_result
end
