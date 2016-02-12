# Get IPMI FRU information

def get_ipmi_fru()
  file_name  = "/ipmi/ipmitool_fru.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process IPMI FRU information

def process_ipmi_fru()
  file_array = get_ipmi_fru()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "IPMI FRU Information"
    row   = [ 'Device / Parameter', 'Value' ]
    table = handle_table("title",title,row,"")
    file_array.each_with_index do |line,index|
      line = line.chomp
      if line.match(/^FRU Device Description/)
        if index > 1
          table = handle_table("line","","",table)
        end
        row = line.split(/\s+:\s+/)
        table = handle_table("row","",row,table)
        next_line = file_array[index+1]
        if !next_line.match(/:/)
          row = [ ' Status', 'Not Present' ]
        else
          row = [ ' Status', 'Present' ]
        end
        table = handle_table("row","",row,table)
      else
        if line.match(/:/)
          row = line.split(/\s+:\s+/)
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No IPMI FRU information available"
  end
  return
end

# Process IPMI

def process_ipmi()
  process_ipmi_fru()
  return
end
