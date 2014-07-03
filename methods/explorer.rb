# Explorer related code

def process_exp_info()
  table = handle_output("title","Explorer Information","","")
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
  table = handle_output("end","","",table)
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
    $exp_file_list = %x[cd #{$work_dir} ; tar -tzf #{$exp_file}].split("\n")
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
    command = "cd #{$work_dir} ; tar -xpzf #{$exp_file} #{file_to_extract} > /dev/null 2>&1"
    if !$exp_file_list[1]
      $exp_file_list = `tar -tzf #{$exp_file}`
      $exp_file_list = $exp_file_list.split(/\n/)
    end
    if $exp_file_list.include?(file_to_extract)
      if $verbose == 1
        puts "Executing: "+command
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
        link_file = link_file.gsub(/\./,"")
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
      puts "File #{file_name} does not exist"
    end
  end
  return file_array
end

# Process explorer version.

def process_exp_ver(table)
  exp_ver = get_exp_ver()
  table = handle_output("row","STB Version",exp_ver,table)
  return table
end

# Get explorer version.

def get_exp_ver()
  file_name  = "/rev"
  file_array = exp_file_to_array(file_name)
  exp_ver    = file_array[0].to_s
  return exp_ver
end

def get_customer_name()
  file_name  = "/defaults"
  file_array = exp_file_to_array(file_name)
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
  if $masked == 0
    table = handle_output("row","Customer",customer_name,table)
  else
    table = handle_output("row","Customer","Company X",table)
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
  table       = handle_output("row","Contract ID",contract_id,table)
  return table
end

# Get Explorer User

def get_exp_user()
  exp_user = search_exp_defaults("EXP_USER_NAME")
  return exp_user
end

def process_exp_user(table)
  exp_user = get_exp_user()
  if $masked == 0
    table = handle_output("row","User",exp_user,table)
  else
    table = handle_output("row","User","Customer X",table)
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
  if $masked == 0
    table = handle_output("row","Email",exp_email,table)
  else
    table = handle_output("row","Email","customre@company.com",table)
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
  if $masked == 0
    table = handle_output("row","Phone",exp_phone,table)
  else
    table = handle_output("row","Phone","XXX-XXXX-XXXX",table)
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
  if $masked == 0
    table = handle_output("row","Country",exp_country,table)
  else
    table = handle_output("row","Country","Country",table)
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
  table       = handle_output("row","Modules",exp_modules,tables)
  return table
end

# List explorers

def list_explorers()
  counter = 0
  if Dir.exist?($exp_dir) or File.symlink?($exp_dir)
    exp_list=Dir.entries($exp_dir)
    if exp_list.grep(/^explorer/)
      title = "Explorers in "+$exp_dir+":"
      table = Terminal::Table.new :title => title, :headings => ['Hostname', 'Date','Host ID','File']
      exp_list.each do |exp_file|
        if exp_file.match(/^explorer/)
          host_info = exp_file.split(/\./)
          if $masked == 1
            orig_name = host_info[2].split(/-/)[0]
            orig_id   = host_info[1]
            host_name = "hostname"+counter.to_s
            counter   = counter+1
            host_id   = "XXXXXXXX"
            exp_file  = exp_file.gsub(/#{orig_id}/,host_id).gsub(/#{orig_name}/,host_name)
          else
            host_name = host_info[2].split(/-/)[0]
            host_id   = host_info[1]
          end
          date_info = host_info[5..6].join(":")+" "+host_info[4]+"/"+host_info[3]+"/"+host_info[2].split(/-/)[1]
          table_row = [ host_name, date_info, host_id, exp_file ]
          table.add_row(table_row)
        end
      end
      puts table
    end
  end
  return
end

