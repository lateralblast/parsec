# Secuirty related code

# Get elfsign information

def get_elfsign()
  file_name = "/crypto/elfsign_verify.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process elfsign insformation

def process_elfsign()
  file_array = get_elfsign()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    source = ""
    title  = "Elfsign Verification"
    row    = [ 'Library / Algorithm', 'Status' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if line.match(/: [A-z]/)
        info    = line.split(/\s+/)
        status  = info[-1]
        library = info[3]
        row     = [ library, status ]
        table   = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No elfsign information"
  end
  return
end

# Process Security (defaults)

def process_security(report_type)
  curr_name  = ""
  table      = ""
  row        = ""
  file_array = ""
  comment    = ""
  handle_output("")
  $defaults.each do |item|
    found      = 0
    items      = item.split(/,/)
    file_name  = items[0]
    param_name = items[1]
    spacer     = items[2]
    rec_val    = items[3]
    if report_type.match(/all|security/) or file_name.match(/#{report_type}/)
      if curr_name != file_name
        if curr_name != ""
          table = handle_table("end","","",table)
        end
        puts
        curr_name  = file_name
        title      = "Security Settings ("+file_name+")"
        row        = ['Item', 'Current','Recommended','Complies']
        table      = handle_table("title",title,row,"")
        file_array = exp_file_to_array(file_name)
        curr_name  = file_name
      end
      if file_array
        file_array.each do |line|
          line.chomp
          if line.match(/^#{param_name}/)
            curr_val = line.split(/#{spacer}/)[1]
            if curr_val
              curr_val = curr_val.gsub(/\s+/,'')
              found    = 1
              if curr_val == rec_val
                comment = "Yes"
              else
                comment = "*No*"
              end
              row   = [param_name,curr_val,rec_val,comment]
              table = handle_table("row","",row,table)
            end
          end
        end
      end
      if found == 0
        curr_val = "N/A"
        comment  = "*No*"
        row      = [param_name,curr_val,rec_val,comment]
        table    = handle_table("row","",row,table)
      end
    end
    if item == $defaults.last
      table = handle_table("end","","",table)
      puts
    end
  end
  case report_type
  when /all|security|cups|snmp/
    process_cups_snmp()
  when /all|security|cups/
    process_cups()
  end
  os_version = get_os_version
  if os_version == "5.11"
    case report_type
    when /all|security|crypto/
      process_crypto_providers()
      process_crypto_list()
    when /all|security|elf/
      process_elfsign()
    end
  end
  return
end
