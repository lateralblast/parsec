# Zone related code

# Process the Zone information.

def process_zones()
  table      = handle_output("title","Zone Information","","")
  file_name  = "/sysconfig/zoneadm-list-iv.out"
  file_array = exp_file_to_array(file_name)
  file_array.each do |line|
    table = handle_output("row","Zone",line,table)
  end
  table = handle_output("end","","",table)
end

