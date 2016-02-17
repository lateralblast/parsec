
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
    puts
    puts "No domain information available"
  end
  return
end
