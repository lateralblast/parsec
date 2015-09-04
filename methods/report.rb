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
  if report_type.match(/all|obp/)
    process_obp()
  end
  if report_type.match(/all|host/)
    process_host()
  end
  if report_type.match(/all|eeprom/)
    process_eeprom()
  end
  if report_type.match(/all|os|core/)
    process_coreadm()
  end
  if report_type.match(/all|os|dump/)
    process_dumpadm()
  end
  if report_type.match(/all|os|exp/)
    process_explorer()
  end
  if report_type.match(/all|os/)
    process_system()
  end
  if report_type.match(/all|cpu/)
    process_cpu()
  end
  if report_type.match(/all|mem/)
    process_memory()
  end
  if report_type.match(/all|io|disk/)
    process_diskinfo()
  end
  if report_type.match(/all|io|disk/)
    process_io()
  end
  if report_type.match(/all|io|disk|swap/)
    process_swap()
  end
  if report_type.match(/all|kernel/)
    process_etc_system()
  end
  if report_type.match(/all|zone/)
    process_zones()
  end
  if report_type.match(/all|security|system|passwd|password|login|sendmail|inetinit|su|inet|cron|keyserv|telnet|power|suspend|ssh/)
    report_type.gsub(/password/,"passwd")
    process_security(report_type)
  end
  if report_type.match(/all|security|inetd/)
    process_inetd()
  end
  if report_type.match(/all|fs|filesystem/)
    process_file_systems()
  end
  if report_type.match(/all|fs|filesystem|mount/)
    if $masked == 0
      process_mounts()
    end
  end
  if report_type.match(/all|services/)
    process_services()
  end
  if report_type.match(/all|lu|liveupgrade|be/)
    os_ver = get_os_version()
    if os_ver.match(/11/)
      process_beadm()
    else
      process_liveupgrade()
    end
  end
  if report_type.match(/all|locale/)
    process_locale()
  end
  if report_type.match(/all|modinfo/)
    process_modules()
  end
  if report_type.match(/all|package/)
    process_packages()
  end
  if report_type.match(/all|patch/)
    process_patches()
  end
  if report_type.match(/all|tcp/)
    process_network("tcp")
  end
  if report_type.match(/all|udp/)
    process_network("udp")
  end
  if report_type.match(/all|ldom/)
    process_ldom()
  end
  if report_type.match(/all|fru/)
    process_fru()
  end
  if report_type.match(/all|handbook/)
    process_handbook()
  end
  handle_output("\n")
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

# Handle output

def handle_output(output)
  if $output_mode == "text"
    print output
  end
  if $output_mode == "file"
    file = File.open($output_file,"a")
    file.write(output)
    file.write("\n")
    file.close()
  end
  return
end

# Generic output routine which formats text appropriately.

def handle_table(type,title,row,table)
  if type.match(/title/)
    handle_output("\n")
    if row.to_s.match(/[A-z]/)
      table = Terminal::Table.new :title => title, :headings => row
    else
      table = Terminal::Table.new :title => title, :headings => ['Item', 'Value']
    end
  end
  if type.match(/end/)
    handle_output(table)
    handle_output("\n")
  end
  if type.match(/line/)
    table.add_separator
  end
  if type.match(/row/)
    if $masked == 1
      if title.match(/Serial|WWN|Domain|Name|directory|nvram|Customer|Contract|User|Email|Phone|Country|Host Name|Host ID|Volume|UUID|MAC|IP|Group|[T,t]ime|[D,d]ate/)
        row = "MASKED"
      end
    end
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
    if file_name
      table = handle_table("row","File",file_name,table)
    end
  else
    table = handle_table("row","File","explorer.tar.gz",table)
  end
  return table
end

# Process explorer directory

def process_dir_name(table)
  if $exp_dir
    table = handle_table("row","Directory",$exp_dir,table)
  end
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
  if file_date
    table = handle_table("row","Date",file_date,table)
  end
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
  if file_time
    table = handle_table("row","Time",file_time,table)
  end
  return table
end
