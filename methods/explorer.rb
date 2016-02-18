# Explorer related code

def process_explorer()
  table = handle_table("title","Explorer Information","","")
  table = process_customer_name(table)
  table = process_contract_id(table)
  table = process_exp_user(table)
  table = process_exp_email(table)
  table = process_exp_phone(table)
  table = process_exp_country(table)
  table = process_dir_name(table)
  table = process_file_name(table)
  table = process_exp_ver(table)
  table = process_file_date(table)
  table = process_file_time(table)
  table = handle_table("end","","",table)
end

# Get file date

def get_extracted_file_date(file_name)
  exp_name = File.basename($exp_file,".tar.gz")
  ext_file = $work_dir+"/"+exp_name+file_name
  if !File.exist?(ext_file)
    extract_exp_file(ext_file)
  end
  file_date = File.mtime(ext_file)
  return(file_date)
end

def check_exp_file_exists(file_name)
  if !$exp_file_list[0]
    if $pigz_bin.match(/pigz/)
      $exp_file_list = %x[cd #{$work_dir} ; pigz -dc #{$exp_file} | tar -tf -].split("\n")
    else
      $exp_file_list = %x[cd #{$work_dir} ; gzip -dc #{$exp_file} | tar -tf -].split("\n")
    end
  end
  check_file = $exp_file_list.grep(/#{file_name}/)
  if check_file
    return file_name
  else
    check_file = ""
    return check_file
  end
end


# Extract a file from the the explorer .tar.gz

def extract_exp_file(file_to_extract)
  if File.exist?($exp_file)
    if $pigz_bin.match(/pigz/)
      command = "cd #{$work_dir} ; pigz -dc #{$exp_file} | tar -xpf - #{file_to_extract} > /dev/null 2>&1"
    else
      command = "cd #{$work_dir} ; gzip -dc #{$exp_file} |tar -xpf - #{file_to_extract} > /dev/null 2>&1"
    end
    if !$exp_file_list[1]
      if $pigz_bin.match(/pigz/)
        $exp_file_list = `pigz -dc #{$exp_file} | tar -tf -`
      else
        $exp_file_list = `gzip -dc #{$exp_file} | tar -tf -`
      end
      $exp_file_list = $exp_file_list.split(/\n/)
    end
    if $exp_file_list.include?(file_to_extract)
      if $verbose == 1
        handle_output("Executing: #{command}\n")
      end
      system(command)
    end
  end
end

# Put the requested file from the explorer into an array.
# Each line is an array element.
# Checks to see if file has already been extracted

def exp_file_to_array(file_name)
  file_array = []
  exp_name   = File.basename($exp_file,".tar.gz")
  ext_file   = $work_dir+"/"+exp_name+file_name
  if !File.exist?(ext_file)
    if !File.symlink?(ext_file)
      arc_file = exp_name+file_name
      extract_exp_file(arc_file)
    end
  end
  if File.exist?(ext_file) or File.symlink?(ext_file)
    link_test = %x[file "#{ext_file}"].chomp
    if link_test.match(/broken symbolic link to/)
      link_file = link_test.split(/broken symbolic link to /)[1]
      if link_file.match(/^\.\//)
        link_file = link_file.gsub(/^\./,"")
        dir_name  = File.dirname(file_name)
      else
        dir_name = ""
      end
      ext_file  = $work_dir+"/"+exp_name+dir_name+link_file
      if !File.exist?(ext_file)
        arc_file = exp_name+dir_name+link_file
        extract_exp_file(arc_file)
      end
    end
    file_array = IO.readlines ext_file
  else
    if $verbose == 1
      handle_output("File #{file_name} does not exist\n")
    end
  end
  return file_array
end

# Process explorer version.

def process_exp_ver(table)
  exp_ver = get_exp_ver()
  table = handle_table("row","STB Version",exp_ver,table)
  return table
end

# Get explorer version.

def get_exp_ver()
  file_name  = "/rev"
  file_array = exp_file_to_array(file_name)
  exp_ver    = file_array[0].to_s
  return exp_ver
end

def search_exp_defaults(search_val)
  file_name  = "/defaults"
  file_array = exp_file_to_array(file_name)
  file_array.each do |line|
    if !line.match(/^#/)
      exp_info = line.split("=")
      exp_val  = exp_info[1].to_s.gsub(/"/,"")
      exp_info = exp_info[0].to_s
      if exp_info.match(/#{search_val}/)
        return exp_val
      end
    end
  end
end

# Get customer name

def get_customer_name()
  customer_name = search_exp_defaults("EXP_CUSTOMER_NAME")
  return customer_name
end

def process_customer_name(table)
  customer_name = get_customer_name()
  if customer_name
    table = handle_table("row","Customer",customer_name,table)
  end
  return table
end

# Get contract ID

def get_contract_id()
  contract_id = search_exp_defaults("EXP_CONTRACT_ID")
  return contract_id
end

def process_contract_id(table)
  contract_id = get_contract_id()
  if contract_id
    table = handle_table("row","Contract ID",contract_id,table)
  end
  return table
end

# Get Explorer User

def get_exp_user()
  exp_user = search_exp_defaults("EXP_USER_NAME")
  return exp_user
end

def process_exp_user(table)
  exp_user = get_exp_user()
  if exp_user
    table = handle_table("row","User",exp_user,table)
  end
  return table
end

# Get Explorer Email

def get_exp_email()
  exp_email = search_exp_defaults("EXP_USER_EMAIL")
  return exp_email
end

def process_exp_email(table)
  exp_email = get_exp_email()
  if exp_email
    table = handle_table("row","Email",exp_email,table)
  end
  return table
end

# Get Explorer Phone

def get_exp_phone()
  exp_phone = search_exp_defaults("EXP_PHONE")
  return exp_phone
end

def process_exp_phone(table)
  exp_phone = get_exp_phone()
  if exp_phone
    table = handle_table("row","Phone",exp_phone,table)
  end
  return table
end

# Get Explorer Country

def get_exp_country()
  exp_country = search_exp_defaults("EXP_ADDRESS_COUNTRY")
  return exp_country
end

def process_exp_country(table)
  exp_country = get_exp_country()
  if exp_country
    table = handle_table("row","Country",exp_country,table)
  end
  return table
end

# Get Explorer Modules

def get_exp_modules()
  exp_modules = search_exp_defaults("EXP_WHICH")
  return exp_modules
end

def process_exp_modules(table)
  exp_modules = get_exp_modules()
  if exp_modules
    table = handle_table("row","Modules",exp_modules,tables)
  end
  return table
end

# List explorers

def list_explorers()
  counter = 0
  if Dir.exist?($exp_dir) or File.symlink?($exp_dir)
    exp_list=Dir.entries($exp_dir).sort
    if exp_list.grep(/^explorer/)
      title = "Explorers in "+$exp_dir+":"
      row   = [ 'Hostname', 'Model', 'Date', 'Host ID', 'File' ]
      table = handle_table("title",title,row,"")
      exp_list.each do |exp_file|
        if exp_file.match(/^explorer/)
          host_info = exp_file.split(/\./)
          host_id    = host_info[1]
          model_name = get_model_from_hostid(host_id)
          if $masked == 1
            orig_name = host_info[2].split(/-/)[0]
            orig_id   = host_info[1]
            host_name = "hostname"+counter.to_s
            counter   = counter+1
            host_id   = "MASKED"
            exp_file  = exp_file.gsub(/#{orig_id}/,host_id).gsub(/#{orig_name}/,host_name)
          else
            host_name  = host_info[2].split(/-/)[0..-2].join("-")
          end
          date_info = host_info[5..6].join(":")+" "+host_info[4]+"/"+host_info[3]+"/"+host_info[2].split(/-/)[1]
          table_row = [ host_name, model_name, date_info, host_id, exp_file ]
          table     = handle_table("row","",table_row,table)
        end
      end
      table = handle_table("end","","",table)
    end
  end
  return
end
