# Patch related code

# Get patch info

def get_patch_info()
  file_name = "/patch+pkg/showrev-p.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get patch dates

def get_patch_dates()
  file_name  = "/patch+pkg/patch_date.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process patch info

def process_patch_info()
  file_array   = get_patch_dates()
  patch_info   = get_patch_info()
  patch_date   = ""
  patch_number = ""
  if file_array
    title = "Patch Information"
    row   = [ 'Patch', 'Install Date', 'Packages' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      if line.match(/^d/)
        items      = line.split(/\s+/)
        patch_no   = items[-1]
        patch_date = items[-5..-2].join(" ")
        patch_pkgs = ""
        patch_pkgs = patch_info.grep(/Patch: #{patch_no}/)[0]
        if patch_pkgs
          patch_pkgs = patch_pkgs.split(/Packages: /)[1]
          patch_pkgs = patch_pkgs.split(/, /)[0..1].join(", ")
        end
        row   = [ patch_no, patch_date, patch_pkgs ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  end
  return
end
