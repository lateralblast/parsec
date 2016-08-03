# Dumpadm related code

# Get dumpadm information

def get_dumpadm_info()
  file_name  = "/sysconfig/dumpadm.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process dumpadm information

def process_dumpadm()
  dumpadm_info = get_dumpadm_info()
  if dumpadm_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    table = handle_table("title","Dumpadm Configuration","","")
    dumpadm_info.each do |line|
      (param,value) = line.split(": ")
      param         = param.gsub(/^\s+/,'')
      if value
        table = handle_table("row",param,value,table)
      end
    end
    table = handle_table("end","","",table)
  else
    handle_output("\n")
    handle_output("No dumpadm information available\n")
  end
  return
end
