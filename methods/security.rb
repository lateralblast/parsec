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
    if !$output_format.match(/table/)
      table = ""
    end
    table = handle_output("\n")
    table = handle_output("No elfsign information\n")
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
    end
  end
  return table
end

# Process passwd defaults

def process_passwd()
  table = process_security("passwd")
  return table
end

# Process login defaults

def process_login()
  table = process_security("login")
  return table
end

# Process sendmail defaults

def process_sendmail()
  table = process_security("sendmail")
  return table
end

# Process inetinit defaults

def process_inetinit()
  table = process_security("inetinit")
  return table
end

# Process su defaults

def process_su()
  table = process_security("su")
  return table
end

# Process inet defaults

def process_inet()
  table = process_security("inet")
  return table
end

# Process cron defaults

def process_cron()
  table = process_security("cron")
  return table
end

# Process keyserv defaults

def process_keyserv()
  table = process_security("keyserv")
  return table
end

# Process telnet defaults

def process_telnet()
  table = process_security("telnetd")
  return table
end

# Process power defaults

def process_power()
  table = process_security("power")
  return table
end

# Process telnet defaults

def process_suspend()
  table = process_security("suspend")
  return table
end

# Process telnet defaults

def process_ssh()
  table = process_security("ssh")
  return table
end
