# Explorer related code

# Handle explorer

def handle_explorer(report,file_list,search_model,search_date,search_year,search_name)
  if !file_list
    file_list = get_explorer_file_list(search_model,search_date,search_year,search_name)
  else
    if !file_list[0]
      file_list = get_explorer_file_list(search_model,search_date,search_year,search_name)
      if file_list[0] == nil
        puts "No explorer files found"
        exit
      end
    end
  end
  file_list.each do |file_name|
    if File.exist?(file_name)
      host_info = file_name.split(/\./)
      host_id   = host_info[1]
      $exp_id   = host_id
      exp_model = get_model_from_hostid(host_id)
      exp_year  = host_info[2].split(/-/)[-1].split(/\./)[0]
      exp_month = host_info[3]
      exp_day   = host_info[4]
      exp_date  = exp_year+"."+exp_month+"."+exp_day
      exp_date  = Date.parse(exp_date).to_s
      exp_time  = host_info[5..6].join(":")
      $exp_key  = exp_date+"."+host_info[5..6].join(".")
      exp_name  = host_info[2].split(/-/)[0..-2].join("-")
      if !$output_file.match(/[A-z]/) and $output_format.match(/pdf/)
        $output_file = $output_dir+"/"+exp_name+"-"+$report_type+".txt"
      end
#      if search_name.match(/^all$/) and $output_format.match(/pdf/)
#        puts $output_file
#        exit
        if File.exist?($output_file)
          File.delete($output_file)
        end
#      end
      if $verbose_mode == 1 and !$output_format.match(/pdf/)
        print "Processing explorer ("+$report_type+") report for "+exp_name
      end
      $exp_file = file_name
      if exp_name.match(/[a-z]|[0-9]/)
        if search_name.match(/^all$/)
          puts "Host: "+exp_name+" Report: "+$report_type
        end
        $exp_file_list = []
        $sys_config    = {}
        config_report(report,exp_name)
        if search_name.match(/^all$/) and $pause_mode == 1
           print "continue (y/n)? "
           STDOUT.flush()
           exit if 'n' == STDIN.gets.chomp
        end
        if $output_format.match(/pdf/)
          pdf = Prawn::Document.new
          if search_name.match(/^all$/)
            output_pdf = $output_dir+"/"+exp_name+".pdf"
          else
            output_pdf = $output_file.gsub(/\.txt$/,".pdf")
          end
          if $verbose_mode == 1
            puts "Input file:  "+$output_file
            puts "Output file: "+output_pdf
          end
          if $masked == 1
            document_title = "Explorer: masked"
          else
            document_title = "Explorer: "+exp_name
          end
          if $masked == 1
            customer_name = "Masked"
          else
            customer_name = get_customer_name()
          end
          generate_pdf(pdf,document_title,output_pdf,customer_name)
        end
      end
    end
  end
end

# Get hostname from explorer filename

def get_hostname_from_explorer_file(exp_file)
  file_name = File.basename(exp_file) 
  host_info = file_name.split(/\./) 
  host_name = host_info[2].split(/-/)[0..-2].join("-")
  return host_name
end

# Process explorers

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
  return table
end

# Get file date

def get_extracted_file_date(file_name)
  exp_name = File.basename($exp_file,".tar.gz")
  ext_file = $work_dir+"/"+exp_name+file_name
  if !File.exist?(ext_file)
    extract_exp_file(ext_file)
  end
  if File.exist?(ext_file)
    file_date = File.mtime(ext_file)
  else
    file_date = "NA"
  end
  return(file_date)
end

def check_exp_file_exists(file_name)
  if !$exp_file_list[0]
    if $tar_bin.match(/star/)
      command = "cd #{$work_dir} ; #{$gzip_bin} -dc #{$exp_file} | #{$tar_bin} -t"
    else
      command = "cd #{$work_dir} ; #{$gzip_bin} -dc #{$exp_file} | #{$tar_bin} -tf -"
    end
    if $verbose_mode == 1
      handle_output("Executing: #{command}\n")
    end
    $exp_file_list = `#{command}`
    $exp_file_list = $exp_file_list.split(/\n/)
  end
  check_file = $exp_file_list.grep(/#{file_name}/)[0]
  if check_file
    if check_file.match(/[A-Z]|[a-z]|[0-9]/)
      return file_name
    else
      check_file = ""
    end
  else
    check_file = ""
    return check_file
  end
end


# Extract a file from the the explorer .tar.gz

def extract_exp_file(file_to_extract)
  if File.exist?($exp_file) or File.symlink?($exp_file)
    ext_file = $work_dir+"/"+file_to_extract
    if !File.exist?(ext_file) and !File.symlink?(ext_file)
      check_file = check_exp_file_exists(file_to_extract)
      if check_file.match(/[A-Z]|[a-z]|[0-9]/)
        if $verbose_mode == 1
          if $tar_bin.match(/star/)
            command = "cd #{$work_dir} ; #{$gzip_bin} -dc #{$exp_file} | #{$tar_bin} -x #{file_to_extract}"
          else
            command = "cd #{$work_dir} ; #{$gzip_bin} -dc #{$exp_file} | #{$tar_bin} -xf - #{file_to_extract}"
          end
        else
          if $tar_bin.match(/star/)
            command = "cd #{$work_dir} ; #{$gzip_bin} -dc #{$exp_file} | #{$tar_bin} -x #{file_to_extract} -silent > /dev/null 2>&1"
          else
            command = "cd #{$work_dir} ; #{$gzip_bin} -dc #{$exp_file} | #{$tar_bin} -xf - #{file_to_extract} > /dev/null 2>&1"
          end
        end
        if $verbose_mode == 1
          handle_output("Executing: #{command}\n")
        end
        system(command)
      end
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
      if $verbose_mode == 1
        handle_output("Extracting #{arc_file} from #{$exp_file} to #{ext_file}\n")
      end
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
    if File.exist?(ext_file)
      file_array = File.readlines(ext_file,:encoding => 'ISO-8859-1')
    else
      file_array = []
    end
  else
    if $verbose == 1
      handle_output("File #{file_name} does not exist\n")
    end
  end
  if !file_array.class == Array
    if !file_array.match(/[A-Z]|[a-z]|[0-9]/)
      file_array = []
    else
      file_array = file_array.split("")
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
  exp_ver    = file_array[0].chomp
  return exp_ver
end

def search_exp_defaults(search_val)
  file_name  = "/defaults"
  file_array = exp_file_to_array(file_name)
  if file_array.to_s.match(/[A-Z]/)
    file_array.each do |line|
      line = line.chomp.gsub(/^\s+/,"")
      if !line.match(/^#/)
        exp_info = line.split("=")
        exp_val  = exp_info[1].to_s.gsub(/"/,"")
        exp_info = exp_info[0].to_s
        if exp_info.match(/#{search_val}/)
          if exp_val.class == "Array"
            exp_val = exp_val[0]
          end
          return exp_val
        end
      end
    end
  else
    exp_val = "None"
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

# Get a list of explorers based on search strings

def get_explorer_file_list(search_model,search_date,search_year,search_name)
  exp_list  = []
  host_list = []
  if Dir.exist?($exp_dir) or File.symlink?($exp_dir)
    file_list = Dir.entries($exp_dir).sort.reject{|entry| entry.match(/\._/)}
    file_list.each do |file_name|
      if file_name.match(/\-/) and file_name.match(/tgz|tar/) and file_name.match(/explorer/)
        host_info = file_name.split(/\./)
        file_name = $exp_dir+"/"+file_name
        host_id   = host_info[1]
        exp_model = get_model_from_hostid(host_id)
        exp_year  = host_info[2].split(/-/)[-1].split(/\./)[0]
        exp_month = host_info[3]
        exp_day   = host_info[4]
        exp_date  = exp_year+"."+exp_month+"."+exp_day
        exp_date  = Date.parse(exp_date).to_s
        exp_time  = host_info[5..6].join(":")
        exp_name  = host_info[2].split(/-/)[0..-2].join("-")
        if !search_model.match(/[a-z,A-Z,0-9]/) or search_model.downcase.match(/#{exp_model.downcase}/) or search_model.match(/^all$/)
          if !search_date.match(/[0-9]/) or exp_date.match(/#{search_date}/) or search_date.match(/^all$/)
            if !search_year.match(/[0-9]/) or exp_year.match(/#{search_year}/) or search_year.match(/^all$/)
              if !search_name.match(/[a-z]/) or exp_name.match(/^#{search_name}$/) or search_name.match(/^all$/)
                if search_name.match(/^all$/)
                  if !host_list.include?(exp_name)
                    exp_list.push(file_name)
                    host_list.push(exp_name)
                  end
                else
                  exp_list.push(file_name)
                end
              end
            end
          end
        end
      end
    end
  end
  if search_name.match(/[a-z]/) and !search_name.match(/all/)
    if search_date.match(/last|latest/)
      tmp_file = exp_list[-1]  
      exp_list = []
      exp_list.push(tmp_file)
    end
    if search_date.match(/first|earliest/)
      tmp_file = exp_list[0]  
      exp_list = []
      exp_list.push(tmp_file)
    end
  end
  return exp_list
end

# List explorers

def list_explorers(search_model,search_date,search_year,search_name)
  counter   = 0
  file_list = get_explorer_file_list(search_model,search_date,search_year,search_name)
  if file_list.to_s.match(/explorer/)
    if $output_format.match(/serverhtml/)
      title = "Explorers:"
    else
      title = "Explorers in "+$exp_dir+":"
    end
    row   = [ 'Hostname', 'Model', 'Year', 'Date', 'Time', 'Host ID', 'File' ]
    table = handle_table("title",title,row,"")
    file_list.each do |file_name|
      host_info = file_name.split(/\./)
      host_id   = host_info[1]
      exp_model = get_model_from_hostid(host_id)
      exp_year  = host_info[2].split(/-/)[-1].split(/\./)[0]
      exp_month = host_info[3]
      exp_day   = host_info[4]
      exp_date  = exp_year+"."+exp_month+"."+exp_day
      exp_date  = Date.parse(exp_date).to_s
      exp_time  = host_info[5..6].join(":")
      exp_name  = host_info[2].split(/-/)[0..-2].join("-")
      if $masked == 1
        temp_name = "hostname"+counter.to_s
        counter   = counter+1
        temp_id   = "masked"
        file_name = file_name.gsub(/#{host_id}/,temp_id).gsub(/#{exp_name}/,temp_name)
        table_row = [ temp_name, exp_model, exp_year, exp_date, exp_time, temp_id, file_name ]
      else
        if $output_format.match(/serverhtml/)
          exp_name  = "<a href=\"/report?server=#{exp_name}&report=host\">#{exp_name}</a>"
          exp_model = "<a href=\"/list?model=#{exp_model}\">#{exp_model}</a>"
          exp_year  = "<a href=\"/list?year=#{exp_year}\">#{exp_year}</a>"
          exp_date  = "<a href=\"/list?date=#{exp_date}\">#{exp_date}</a>"
          file_name = File.basename(file_name)
        end
        table_row = [ exp_name, exp_model, exp_year, exp_date, exp_time, host_id, file_name ]
      end
      table     = handle_table("row","",table_row,table)
    end
    table = handle_table("end","","",table)
    if $output_format.match(/serverhtml/)
      new_table = []
      new_table.push("<a href=\"/help\">HELP</a>")
      new_table.push("<a href=\"/list\">LIST</a>")
      new_table.push("<a href=\"/upload\">UPLOAD</a>")
      new_table = new_table + table
      table     = new_table
    end
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No explorer information available\n")
    else 
      table = ""
      table = handle_output("\n")
      table = handle_output("No explorer information available\n")
    end
  end
  return table
end
