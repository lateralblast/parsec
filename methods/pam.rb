# PAM information

# Get PAM information

def get_pam()
  file_name = "/etc/pam.conf"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process diskinfo insformation

def process_pam()
  os_ver = get_os_ver()
  if os_ver.match(/11/)
    file_list = [ 'cron', 'cups', 'gdm-autologin', 'krlogin', 'krsh', 'ktelnet', 'login', 'other', 'passwd', 'pfexec', 'ppp', 'rlogin', 'rsh', 'tpdlogin' ]
    file_list.each do |file_name|
      pam_file = "/etc/pam.d/"+file_name
      file_array = exp_file_to_array(pam_file)
      if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
        title  = "PAM Information ("+pam_file+")"
        row    = [ 'Service', 'Security', 'Library', 'Arguments' ]
        table  = handle_table("title",title,row,"")
        file_array.each do |line|
          line = line.chomp
          if !line.match(/^#/) and line.match(/[a-z]/)
            row = line.split(/\s+/)
            if !row[3]
              row[3] = ""
            else
              row[3] = row[3..-1].join(" ")
            end
            table = handle_table("row","",row,table)
          end
        end
        table = handle_table("end","","",table)
      else
        handle_output("\n")
        handle_output("No PAM information available for #{file_name}\n")
      end
    end
  else
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
      handle_output("\n")
      handle_output("No PAM information available\n")
    end
  end
  return
end
