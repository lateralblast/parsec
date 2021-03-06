# CUPS

# Get CUPS information

def get_cups()
  file_name = "/cups/cupsd.conf"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process CUPS insformation

def process_cups()
  file_array = get_cups()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    source = ""
    title  = "CUPS Configuration"
    row    = [ 'Item', 'Value' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if line.match(/^[A-z]/)
        info  = line.split(/\s+/)
        item  = info[0]
        value = info[1..-1].join(" ")
        row   = [ item, value ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No CUPS information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No CUPS information available\n")
    end
  end
  return table
end
