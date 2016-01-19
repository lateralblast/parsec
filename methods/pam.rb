# PAM information

# Get PAM information

def get_pam()
  file_name = "/etc/pam.conf"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process diskinfo insformation

def process_pam()
  file_array = get_pam()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    source = ""
    title  = "PAM Information"
    row    = [ 'Service', 'Type', 'Security', 'Library', 'Arguments' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^#/) and line.match(/[a-z]/)
        row = line.split(/\s+/)
        if !row[4]
          row[4] = ""
        else
          row[4] = row[4..-1].join(" ")
        end
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No PAM information available"
  end
  return
end
