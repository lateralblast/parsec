# Coreadm related code

# Get coreadm information

def get_coreadm_info()
  file_name  = "/sysconfig/coreadm.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process coreadm infomation

def process_coreadm()
  coreadm_info = get_coreadm_info()
  if coreadm_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    table = handle_table("title","Coreadm Configuration","","")
    coreadm_info.each do |line|
      (param,value) = line.split(": ")
      if param and value
        param = param.gsub(/^\s+/,'')
        table = handle_table("row",param,value,table)
      end
    end
    table = handle_table("end","","",table)
  else
    handle_output("\n")
    handle_output("No coreadm infomation available\n")
  end
  return
end
