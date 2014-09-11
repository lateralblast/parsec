# Timezone related code

# Get the Time Zone

def get_time_zone()
  file_name  = "/etc/TIMEZONE"
  file_array = exp_file_to_array(file_name)
  if !file_array
    time_zone = ""
  else
    time_zone = file_array.grep(/^TZ/)[0].split("=")[1].chomp
  end
  return time_zone
end

# Process Time Zone

def process_time_zone(table)
  time_zone = get_time_zone()
  if time_zone
    table = handle_table("row","Timezone",time_zone,table)
  end
  return table
end
