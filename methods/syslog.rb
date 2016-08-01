# Syslog information

# Get syslog information

def get_syslog()
  file_name = "/etc/syslog.conf"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process diskinfo insformation

def process_syslog()
  file_array = get_syslog()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    source = ""
    title  = "Syslog Information"
    row    = [ 'Source', 'Destination' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^#|^ifdef/) and line.match(/[a-z]/)
        items = line.split(/\s+/)
        row   = [ items[0], items[1..-1].join(" ") ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if !$output_file.match(/[A-z]/)
      puts
      puts "No syslog information available"
    end
  end
  return
end
