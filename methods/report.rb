# Report related code

# Specify option to report on

def report_help(report,report_type)
  if report[report_type]
    puts report_type+": "+report[report_type]
  else
    puts "No option for "+report_type+" exists"
    puts
    puts "The following options exist:"
    puts
    report.each do |key, value|
      if key.length < 7
        puts key+":\t\t"+value
      else
        puts key+":\t"+value
      end
    end
    puts
  end
end

# Do configuration report

def config_report(report,report_type)
  case report_type
  when /all|obp/
    process_obp_info()
  when /all|host/
    process_host_info()
  when /all|eeprom/
    process_eeprom_info()
  when /all|os/
    process_coreadm_info()
  when /all|os/
    process_dumpadm_info()
  when /all|os/
    process_exp_info()
  when /all|os/
    process_sys_info()
  when /all|cpu/
    process_cpu_info()
  when /all|memory/
    process_mem_info()
  when /all|io|disk/
    process_io_info()
  when /all|kernel/
    process_etc_sys_info()
  when /all|zones/
    process_zones()
  when /all|security|system|passwd|login|sendmail|inetinit|su|inetd|cront|keyserv|telnetd|power|suspend|sshd/
    process_security(report_type)
  when /all|security|inetd/
    process_inetd()
  when /all|fs/
    process_file_systems()
  when /all|services/
    process_services()
  when /all|lu/
    process_lu_info()
  when /all|locale/
    process_locale_info()
  when /all|modinfo/
    process_mod_info()
  when /all|package/
    process_pkg_info()
  when /all|patch/
    process_patch_info()
  when /all|tcp/
    process_ip_info("tcp")
  when /all|udp/
    process_ip_info("udp")
  when /all|ldom/
    process_ldom_info()
  end
  puts
  return
end

def clean_up()
  exp_name = File.basename($exp_file,".tar.gz")
  exp_dir  = $work_dir+"/"+exp_name
  if Dir.exist?(exp_dir)
    FileUtils.rm_rf(exp_dir)
  end
  return
end

# Open Disk firmware file
# file generated from output of goofball
# goofball.rb -d all -c

def info_file_to_array(file_name)
  info_file = $base_dir+"/information/"+file_name
  if File.exist?(info_file)
    file_array = IO.readlines info_file
  end
  return file_array
end

# Compare versions

def compare_ver(curr_fw,avail_fw)
  ord_avail_fw = []
  counter      = 0
  avail_fw     = avail_fw.split(".")
  while counter < avail_fw.length
    digit = avail_fw[counter]
    if digit.match(/[A-z]/)
      ord_avail_fw[counter] = digit.ord
    else
      ord_avail_fw[counter] = digit
    end
    counter = counter+1
  end
  ord_avail_fw = ord_avail_fw.join(".")
  avail_fw     = avail_fw.join(".")
  ord_curr_fw  = []
  counter      = 0
  curr_fw      = curr_fw.split(".")
  while counter < curr_fw.length
    digit = curr_fw[counter]
    if digit.match(/[A-z]/)
      ord_curr_fw[counter] = digit.ord
    else
      ord_curr_fw[counter] = digit
    end
    counter = counter+1
  end
  ord_curr_fw  = ord_curr_fw.join(".")
  curr_fw      = curr_fw.join(".")
  versions     = [ ord_curr_fw, ord_avail_fw ]
  latest_fw    = versions.map{ |v| (v.split '.').collect(&:to_i) }.max.join '.'
  if latest_fw == ord_curr_fw
    return curr_fw
  else
    return avail_fw
  end
end
# Generic output routine which formats text appropriately.

def handle_output(type,title,row,table)
  if type.match(/title/)
    puts
    if row.to_s.match(/[A-z]/)
      table = Terminal::Table.new :title => title, :headings => row
    else
      table = Terminal::Table.new :title => title, :headings => ['Item', 'Value']
    end
  end
  if type.match(/end/)
    puts table
  end
  if type.match(/line/)
    table.add_separator
  end
  if type.match(/row/)
    if title.match(/[A-z]/)
      row = [title,row]
    end
    if row.length == 2
      item  = row[0]
      value = row[1]
      $host_info[item] = value
    end
    table.add_row(row)
  end
  return table
end

# Search file name

def search_file_name(field)
  field_val = Pathname.new($exp_file)
  field_val = field_val.basename
  field_val = field_val.to_s.split(".")
  field_val = field_val[field].to_s
  return field_val
end

# Process file name

def process_file_name(table)
  file_name = Pathname.new($exp_file)
  file_name = file_name.basename.to_s
  if $masked == 0
    table = handle_output("row","File",file_name,table)
  else
    table = handle_output("row","File","explorer.tar.gz",table)
  end
  return table
end

# Process explorer directory

def process_dir_name(table)
  table = handle_output("row","Directory",$exp_dir,table)
  return table
end

# Get file date

def get_file_date()
  file_year  = search_file_name(2)
  file_year  = file_year.to_s.split("-")
  file_year  = file_year[1].to_s
  file_month = search_file_name(3)
  file_day   = search_file_name(4)
  file_date  = file_day+"/"+file_month+"/"+file_year
  return file_date
end

def process_file_date(table)
  file_date = get_file_date()
  table     = handle_output("row","Date",file_date,table)
  return table
end

# Get file time

def get_file_time()
  file_hour = search_file_name(5)
  file_min  = search_file_name(6)
  file_hour = file_hour.to_s
  file_min  = file_min.to_s
  file_time = file_hour+":"+file_min
  return file_time
end

def process_file_time(table)
  file_time = get_file_time()
  table     = handle_output("row","Time",file_time,table)
  return table
end
