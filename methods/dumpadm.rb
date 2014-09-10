# Dumpadm related code

# Get dumpadm information

def get_dumpadm_info()
  file_name  = "/sysconfig/dumpadm.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process dumpadm infomation

def process_dumpadm()
  table        = handle_table("title","Dumpadm Configuration","","")
  dumpadm_info = get_dumpadm_info()
  dumpadm_info.each do |line|
    (param,value) = line.split(": ")
    param         = param.gsub(/^\s+/,'')
    if param.match(/directory/)
      if $masked == 0
        if value
          table = handle_table("row",param,value,table)
        end
      end
    else
      if value
        table = handle_table("row",param,value,table)
      end
    end
  end
  table = handle_table("end","","",table)
  return
end
