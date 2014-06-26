# Locale related code

# Process Locale info

def get_locale_info()
  file_name  = "/sysconfig/locale.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def process_locale_info()
  file_array = get_locale_info()
  if file_array
    title = "Locale Information"
    table = handle_output("title",title,"","")
    file_array.each do |line|
      items      = line.split(/\=/)
      locale_str = items[0]
      locale_val = items[1]
      locale_val = locale_val.gsub(/"/,'')
      row        = [locale_str,locale_val]
      table      = handle_output("row","",row,table)
    end
    table = handle_output("end","","",table)
  end
  return
end
