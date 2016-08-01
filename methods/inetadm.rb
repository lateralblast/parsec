# Syslog information

# Get syslog information

def get_inetadm()
  file_name = "/sysconfig/inetadm.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process diskinfo insformation

def process_inetadm()
  file_array = get_inetadm()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title  = "Inetadm Information"
    row    = [ 'Enabled', 'Status', 'FMRI' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^ENABLED/) and line.match(/[a-z]/)
        row   = line.split(/\s+/)
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    handle_output("\n")
    handle_output("No inetadm information available")
  end
  return
end
