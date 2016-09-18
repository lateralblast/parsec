# Locale related code

# Process Locale info

def get_locale_info()
  file_name  = "/sysconfig/locale.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def process_locale()
  file_array = get_locale_info()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "Locale Information"
    table = handle_table("title",title,"","")
    file_array.each do |line|
      line       = line.chomp
      items      = line.split(/\=/)
      locale_str = items[0]
      locale_val = items[1]
      if locale_val
        locale_val = locale_val.gsub(/"/,'')
      else
        locale_val = ""
      end
      row        = [locale_str,locale_val]
      table      = handle_table("row","",row,table)
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No locale information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No locale information available\n")
    end
  end
  return table
end
