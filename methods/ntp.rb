# NTP information

# Get ntpq information

def get_ntpq()
  file_name = "/sysconfig/ntpq-p.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get NTP config

def get_ntp_config()
  file_name = "/etc/inet/ntp.conf"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process NTP insformation

def process_ntp()
  table   = []
  t_table = process_ntp_config()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_ntpq()
  if t_table.class == Array
    table = table + t_table
  end
  return table
end

# Process NTP config

def process_ntp_config()
  file_array = get_ntp_config()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title  = "NTP Configuration Information"
    row    = [ 'Parameter', 'Value' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^#|^ifdef/) and line.match(/[a-z]/)
        items = line.split(/\s+/)
        if line.match(/server/) and $masked == 1
          row   = [ items[0], "MASKED" ]
        else
          row   = [ items[0], items[1..-1].join(" ") ]
        end
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if !$output_format.match(/table/)
      table = ""
    end
    handle_output("\n")
    handle_output("No NTP information available\n")
  end
  return table
end

# Process ntpq information

def process_ntpq()
  file_array = get_ntpq()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    table = ""
    file_array.each do |line|
      if !line.match(/^#|^=/)
        line = line.gsub(/^\s+/,"")
        row  = line.split(/\s+/)
        if line.match(/refid/)
          title  = "NTPQ Information"
          table  = handle_table("title",title,row,"")
        else
          if $masked == 1
            row[0] = "MASKED"
            row[1] = "MASKED"
          end
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    if !$output_format.match(/table/)
      table = ""
    end
    handle_output("\n")
    handle_output("No NTPQ information available\n")
  end
  return table
end
