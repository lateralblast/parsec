
# Get Domain information

def get_domain_info()
  file_name  = "/sysconfig/virtinfo-a.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process Domain information

def process_domain()
  model_name = get_model_name()
  if model_name.match(/^M[5-7]-/)
    file_array = get_domain_info()
    if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
      handle_output("\n")
      title   = "Domain Information"
      row     = ['Item','Value']
      table   = handle_table("title",title,row,"")
      file_array.each do |line|
        line  = line.chomp
        items = line.split(/: /)
        item  = items[0]
        value = items[1]
        row   = [ item, value ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No domain information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No domain information available\n")
    end
  end
  return table
end
