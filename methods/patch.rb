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

def process_patches()
  os_ver = get_os_version()
  if os_ver.match(/11/)
    handle_output("\n")
    handle_output("No VNIC information available\n")
  end
  file_array   = get_patch_dates()
  patch_info   = get_patch_info()
  patch_date   = ""
  patch_number = ""
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "Patch Information"
    row   = [ 'Patch', 'Install Date', 'Packages' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
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
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No patch information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No patch information available\n")
    end
  end
  return table
end
