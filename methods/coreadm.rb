# Coreadm related code

# Get coreadm information

def get_coreadm_info()
  file_name  = "/sysconfig/coreadm.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process coreadm infomation

def process_coreadm_info()
  table        = handle_output("title","Coreadm Configuration","","")
  coreadm_info = get_coreadm_info()
  coreadm_info.each do |line|
    (param,value) = line.split(": ")
    param         = param.gsub(/^\s+/,'')
    table         = handle_output("row",param,value,table)
  end
  table = handle_output("end","","",table)
  return
end
