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
      items      = line.split(/\=/)
      locale_str = items[0]
      locale_val = items[1]
      locale_val = locale_val.gsub(/"/,'')
      row        = [locale_str,locale_val]
      table      = handle_table("row","",row,table)
    end
    table = handle_table("end","","",table)
  else
    if !$output_file.match(/[A-z]/)
      puts
      puts "No locale information available"
    end
  end
  return
end
