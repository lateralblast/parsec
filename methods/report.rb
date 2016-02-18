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

def config_report(report,report_type,host_name)
  if $output_mode == "html"
    puts "<html>"
    puts "<head>"
    puts "<title>Explorer report for #{host_name}</title>"
    puts "</head>"
    puts "<body>"
  end
  if report_type.match(/all|host/)
    process_host()
  end
  if report_type.match(/all|security|ntp/)
    process_ntp()
  end
  if report_type.match(/all|inetadm/)
    process_inetadm()
  end
  if report_type.match(/all|security|pam/)
    process_pam()
  end
  if report_type.match(/all|syslog/)
    process_syslog()
  end
  if report_type.match(/all|cups/)
    process_cups()
  end
  if report_type.match(/all|obp/)
    process_obp()
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
  if report_type.match(/all|disk/)
    process_disk_info()
  end
  if report_type.match(/all|io/)
    process_io()
  end
  if report_type.match(/all|swap/)
    process_swap()
  end
  if report_type.match(/all|vnic/)
    os_ver = get_os_version()
    if get_os_version.match(/11/)
      process_vnic()
    else
      puts
      puts "No VNIC information available"
    end
  end
  if report_type.match(/all|link/)
    os_ver = get_os_version()
    if get_os_version.match(/11/)
      process_link()
    else
      puts
      puts "No link information available"
    end
  end
  if report_type.match(/all|kernel|ndd/)
    process_etc_system()
    process_ndd_ip_info()
    process_ndd_tcp_info()
    process_ndd_udp_info()
    process_ndd_arp_info()
    process_ndd_icmp_info()
    process_ndd_sctp_info()
  end
  if report_type.match(/all|security|elfsign/)
    process_elfsign()
  end
  if report_type.match(/all|zone/)
    process_zones()
  end
  if report_type.match(/all|security|system|passwd|password|login|sendmail|inetinit|su|inet|cron|keyserv|telnet|power|suspend|ssh|crypto|snmp|cups/)
    report_type.gsub(/password/,"passwd")
    process_security(report_type)
  end
  if report_type.match(/all|security|inetd/)
    process_inetd()
  end
  if report_type.match(/all|^fs|filesystem/)
    process_file_systems()
  end
  if report_type.match(/all|^fs|filesystem|mount/)
    if $masked == 0
      process_mounts()
    end
  end
  if report_type.match(/all|filesystem|zfs/)
    os_ver = get_os_version()
    if os_ver.match(/10|11/)
      process_zfs()
    else
      puts
      puts "No ZFS information available"
    end
  end
  if report_type.match(/all|services/)
    process_service_descs()
    process_services()
    process_service_deps()
  end
  if report_type.match(/all|lu|liveupgrade|be/)
    os_ver = get_os_version()
    if os_ver.match(/11/)
      process_beadm()
    else
      process_liveupgrade()
    end
  end
  if report_type.match(/all|svcprop/)
    os_ver = get_os_version()
    if os_ver.match(/11/)
      process_svcprop()
    else
      puts
      puts "No service property information available"
    end
  end
  if report_type.match(/all|locale/)
    process_locale()
  end
  if report_type.match(/all|modinfo|module/)
    process_modules()
  end
  if report_type.match(/all|package/)
    process_packages()
  end
  if report_type.match(/all|patch/)
    os_ver = get_os_version
    if !os_ver.match(/11/)
      process_patches()
    else
      puts
      puts "No patch information available"
    end
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
  if report_type.match(/all|^dom/)
    process_domain()
  end
  if report_type.match(/all|fru/)
    process_fru()
  end
  if report_type.match(/all|sensor/)
    process_sensors()
  end
  if report_type.match(/all|handbook/)
    process_handbook()
  end
  if report_type.match(/all|veritas|vx/)
    process_veritas()
  end
  if report_type.match(/all|aggr|network/)
    process_aggr()
  end
  if report_type.match(/all|network/)
    process_nic_info()
  end
  if report_type.match(/^serial$/)
    serial = get_chassis_serial()
    puts serial
    exit
  end
  if report_type.match(/all|serials/)
    process_serials()
  end
  if report_type.match(/all|firmware/)
    process_firmware()
  end
  if report_type.match(/all|ipmi/)
    process_ipmi()
  end
  if report_type.match(/all|slots/)
    process_upgrade_slots()
  end
  if report_type.match(/all|pci/)
    process_pci_scan()
  end
  if $output_mode == "html"
    puts "</body>"
    puts "</html>"
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
  if $output_mode == "text" or $output_mode == "pipe"
    if $output_mode == "pipe"
      output = output.to_s
      output = output.split(/\n/)
      output.each do |line|
        line = line.gsub(/^\s+/,"")
        if line.match(/[0-9]|[A-Z]|[a-z]/)
          puts line
        end
      end
    else
      print output
    end
  end
  if $output_mode == "html"
    if output.class == String
      puts "<p>#{output}</p>"
    else
      puts "<p>"
      output.each do |line|
        puts "#{line}"
      end
      puts "<br>"
    end
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
    if $output_mode == "html"
      table = []
      table.push("<h1>#{title}</h1>")
      table.push("<table border=\"1\">")
    end
    if row.to_s.match(/[A-z]/)
      if $output_mode == "html"
        row.each do |heading|
          table.push("<th>#{heading}</th>")
        end
      else
        if $output_mode == "pipe"
          title = "::"+title
          table = Terminal::Table.new :title => title, :style => { :border_x => "", :border_y => "", :border_i => "" }, :headings => row
        else
          table = Terminal::Table.new :title => title, :headings => row
        end
      end
    else
      if $output_mode == "html"
        table.push("<th>Item</th>")
        table.push("<th>Value</th>")
      else
        if $output_mode == "pipe"
          title = "::"+title
          table = Terminal::Table.new :title => title, :style => { :border_x => "", :border_y => "", :border_i => "" }, :headings => ['Item', 'Value']
        else
          table = Terminal::Table.new :title => title, :headings => ['Item', 'Value']
        end
      end
    end
  end
  if type.match(/end/)
    if $output_mode == "html"
      table.push("</table>")
    else
      handle_output(table)
      handle_output("\n")
    end
  end
  if type.match(/line/)
    if !$output_mode == "html"
      table.add_separator
    end
  end
  if type.match(/row/)
    if $masked == 1
      if row.class == String
        if title.match(/Serial|WWN|Domain|Name|Mount|[D,d]irectory|nvram|Customer|Contract|User|Email|Phone|Country|Host Name|Host ID|Volume|UUID|MAC|IP|Group|[T,t]ime|[D,d]ate/)
          row = "MASKED"
        end
      else
        if row
          row.each.with_index do |value,index|
            case row
            when /[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]/
              row[index] = "MASKED"
            else
              row[index] = value
            end
          end
        end
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
    if $output_mode == "html"
      table.push("<tr>")
      row.each do |value|
        table.push("<td>#{value}</td>")
      end
      table.push("</tr>")
    else
      table.add_row(row)
    end
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
  host_info  = Pathname.new($exp_file)
  host_info  = host_info.basename
  host_info  = host_info.to_s.split(/\./)
  year_info  = host_info[2].split(/-/)[-1].split(/\./)[0]
  month_info = host_info[3]
  day_info   = host_info[4]
  file_date  = day_info+"/"+month_info+"/"+year_info
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
