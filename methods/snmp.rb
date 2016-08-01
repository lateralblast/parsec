# SNMP

# Get CUPS SNMP information

def get_cups_snmp()
  file_name = "/cups/snmp.conf"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process CUPS SNMP insformation

def process_cups_snmp()
  file_array = get_cups_snmp()
  if file_array.to_s.match(/[A-Z]|[a-z]/)
    source = ""
    title  = "CUPS SNMP Configuration"
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
    handle_output("No CUPS SNMP information available")
  end
  return
end