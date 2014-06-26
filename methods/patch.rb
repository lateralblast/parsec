# Patch related code

# Process patch info

def get_patch_info()
  file_name  = "/patch+pkg/patch_date.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def process_patch_info()
  file_array   = get_patch_info()
  patch_date   = ""
  patch_number = ""
  if file_array
    title = "Patch Information"
    row   = ['Patch','Install Date']
    table = handle_output("title",title,row,"")
    file_array.each do |line|
      if line.match(/^d/)
        items        = line.split(/\s+/)
        patch_number = items[-1]
        patch_date   = items[-5..-2].join(" ")
        row          = [patch_number,patch_date]
        table        = handle_output("row","",row,table)
      end
    end
    table = handle_output("end","","",table)
  end
  return
end
