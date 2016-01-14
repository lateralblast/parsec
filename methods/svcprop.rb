# Beadm related code

def get_svcprop_info()
  file_name  = "/sysconfig/svcprop.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process Beadm info

def process_svcprop()
  file_array = get_svcprop_info()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    handle_output("\n")
    counter = 0
    title   = "Service Properties"
    row     = [ 'Service', 'Property','Type','Value' ]
    table   = handle_table("title",title,row,"")
    file_array.each do |line|
      line     = line.chomp
      line     = line.gsub(/\n/," ").gsub(/\s+/," ")
      items    = line.split(/\:/)
      service  = items[1]
      property = items[2]
      suffix   = items[3]
      if suffix
        values   = suffix.split(/ /)
        param    = values[0]
        if values[1]
          type = values[1]
        end
        if values[2]
          value = values[2..-1].join(" ")[0..20]
        end
        row      = [ service, property, type, value ]
        table    = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No service property information available"
  end
  return
end
