# Beadm related code

def get_beadm_status()
  file_name  = "/patch+pkg/beadm_list_-a.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process Beadm info

def process_beadm()
  file_array = get_beadm_status()
  lu_current = ""
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    handle_output("\n")
    counter = 0
    title   = "Boot Environment Status"
    row     = [ 'Name', 'Active','Mountpoint','Space', 'Policy', 'Created' ]
    table   = handle_table("title",title,row,"")
    file_array.each do |line|
      line       = line.chomp
      line       = line.gsub(/^\s+/,"")
      items      = line.split(/\s+/)
      be_name    = items[0]
      if !be_name.match(/BE|--/)
        be_active  = items[1]
        be_mount   = items[2]
        be_space   = items[3]
        be_policy  = items[4]
        be_created = items[5]
        row        = [ be_name, be_active, be_mount, be_space, be_policy, be_created ]
        table      = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    handle_output("\n")
    handle_output("No BE information available\n")
  end
  return
end
