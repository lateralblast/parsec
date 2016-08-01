# Report related code

# Specify option to report on

def report_help(report)
  if report[$report_type]
    puts $report_type+": "+report[$report_type]
  else
    puts "No option for "+$report_type+" exists"
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

def config_report(report,host_name)
  valid_sw = 0
  if $output_format.match(/html/)
    puts "<html>"
    puts "<head>"
    puts "<title>Explorer report for #{host_name}</title>"
    puts "</head>"
    puts "<body>"
  end
  if $report_type.match(/all|host/)
    valid_sw = 1
    process_host()
  end
  if $report_type.match(/all|security|ntp/)
    process_ntp()
  end
  if $report_type.match(/all|inetadm/)
    valid_sw = 1
    process_inetadm()
  end
  if $report_type.match(/all|security|pam/)
    valid_sw = 1
    process_pam()
  end
  if $report_type.match(/all|syslog/)
    valid_sw = 1
    process_syslog()
  end
  if $report_type.match(/all|cups/)
    valid_sw = 1
    process_cups()
  end
  if $report_type.match(/all|obp/)
    valid_sw = 1
    process_obp()
  end
  if $report_type.match(/all|eeprom/)
    valid_sw = 1
    process_eeprom()
  end
  if $report_type.match(/all|os|core/)
    valid_sw = 1
    process_coreadm()
  end
  if $report_type.match(/all|os|dump/)
    valid_sw = 1
    process_dumpadm()
  end
  if $report_type.match(/all|os|exp/)
    valid_sw = 1
    process_explorer()
  end
  if $report_type.match(/all|os/)
    valid_sw = 1
    process_system()
  end
  if $report_type.match(/all|cpu/)
    valid_sw = 1
    process_cpu()
  end
  if $report_type.match(/all|mem/)
    valid_sw = 1
    process_memory()
  end
  if $report_type.match(/all|disk/)
    valid_sw = 1
    process_disk_info()
  end
  if $report_type.match(/all|io/)
    valid_sw = 1
    process_io()
  end
  if $report_type.match(/all|swap/)
    valid_sw = 1
    process_swap()
  end
  if $report_type.match(/all|vnic/)
    valid_sw = 1
    os_ver = get_os_version()
    if get_os_version.match(/11/)
      process_vnic()
    else
      handle_output("\n")
      handle_output("No VNIC information available")
    end
  end
  if $report_type.match(/all|link/)
    valid_sw = 1
    os_ver = get_os_version()
    if get_os_version.match(/11/)
      process_link()
    else
      handle_output("\n")
      handle_output("No link information available")
    end
  end
  if $report_type.match(/all|kernel|ndd/)
    valid_sw = 1
    process_etc_system()
    process_ndd_ip_info()
    process_ndd_tcp_info()
    process_ndd_udp_info()
    process_ndd_arp_info()
    process_ndd_icmp_info()
    process_ndd_sctp_info()
  end
  if $report_type.match(/all|security|elfsign/)
    valid_sw = 1
    process_elfsign()
  end
  if $report_type.match(/all|zone/)
    valid_sw = 1
    process_zones()
  end
  if $report_type.match(/all|security|system|passwd|password|login|sendmail|inetinit|su|inet|cron|keyserv|telnet|power|suspend|ssh|crypto|snmp|cups/)
    $report_type.gsub(/password/,"passwd")
    valid_sw = 1
    process_security($report_type)
  end
  if $report_type.match(/all|security|inetd/)
    valid_sw = 1
    process_inetd()
  end
  if $report_type.match(/all|^fs|filesystem/)
    valid_sw = 1
    process_file_systems()
  end
  if $report_type.match(/all|^fs|filesystem|mount/)
    valid_sw = 1
    if $masked == 0
      process_mounts()
    end
  end
  if $report_type.match(/all|filesystem|zfs/)
    valid_sw = 1
    os_ver = get_os_version()
    if os_ver.match(/10|11/)
      process_zfs()
    else
      handle_output("\n")
      handle_output("No ZFS information available")
    end
  end
  if $report_type.match(/all|services/)
    valid_sw = 1
    process_service_descs()
    process_services()
    process_service_deps()
  end
  if $report_type.match(/all|lu|liveupgrade|be/)
    valid_sw = 1
    os_ver = get_os_version()
    if os_ver.match(/11/)
      process_beadm()
    else
      process_liveupgrade()
    end
  end
  if $report_type.match(/svcprop/)
    valid_sw = 1
    os_ver = get_os_version()
    if os_ver.match(/11/)
      process_svcprop()
    else
      handle_output("\n")
      handle_output("No service property information available")
    end
  end
  if $report_type.match(/all|locale/)
    valid_sw = 1
    process_locale()
  end
  if $report_type.match(/all|modinfo|module/)
    valid_sw = 1
    process_modules()
  end
  if $report_type.match(/all|package/)
    valid_sw = 1
    process_packages()
  end
  if $report_type.match(/all|patch/)
    valid_sw = 1
    os_ver = get_os_version
    if !os_ver.match(/11/)
      process_patches()
    else
      handle_output("\n")
      handle_output("No patch information available")
    end
  end
  if $report_type.match(/all|tcp/)
    valid_sw = 1
    process_network("tcp")
  end
  if $report_type.match(/all|udp/)
    valid_sw = 1
    process_network("udp")
  end
  if $report_type.match(/all|ldom/)
    valid_sw = 1
    process_ldom()
  end
  if $report_type.match(/all|^dom/)
    valid_sw = 1
    process_domain()
  end
  if $report_type.match(/all|fru/)
    valid_sw = 1
    process_fru()
  end
  if $report_type.match(/all|sensor/)
    valid_sw = 1
    process_sensors()
  end
  if $report_type.match(/all|handbook/)
    valid_sw = 1
    process_handbook()
  end
  if $report_type.match(/all|veritas|vx/)
    valid_sw = 1
    process_veritas()
  end
  if $report_type.match(/all|aggr|network/)
    valid_sw = 1
    process_aggr()
  end
  if $report_type.match(/all|network/)
    valid_sw = 1
    process_nic_info()
  end
  if $report_type.match(/^serial$/)
    valid_sw = 1
    serial = get_chassis_serial()
    handle_output(serial)
    exit
  end
  if $report_type.match(/all|serials/)
    valid_sw = 1
    process_serials()
  end
  if $report_type.match(/all|firmware/)
    valid_sw = 1
    process_firmware()
  end
  if $report_type.match(/all|ipmi/)
    valid_sw = 1
    process_ipmi()
  end
  if $report_type.match(/all|slots/)
    valid_sw = 1
    process_upgrade_slots()
  end
  if $report_type.match(/all|pci/)
    valid_sw = 1
    process_pci_scan()
  end
  if $report_type.match(/all|sds|svm|disksuite/)
    valid_sw = 1
    process_svm()
  end
  if $output_format.match(/html/)
    puts "</body>"
    puts "</html>"
  end
  handle_output("\n")
  if valid_sw == 0
    report_help(report)
    handle_output("\n")
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
  if $output_file.match(/[A-z]/)
    file = File.open($output_file,"a")
    file.write(output)
    file.write("\n")
    file.close()
  else
    if $output_format.match(/table|pdf|pipe/)
      if $output_format.match(/pipe/)
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
    if $output_format.match(/html/)
      if output.class == String
        if output.match(/[A-z]/)
          puts "<p>#{output}</p>"
        end
      else
        puts "<p>"
        output.each do |line|
          puts "#{line}"
        end
        puts "<br>"
      end
    end
  end
  return
end

# Generic output routine which formats text appropriately.

def handle_table(type,title,row,table)
  if type.match(/title/)
    handle_output("\n")
    if $output_format.match(/html/)
      table = []
      table.push("<h1>#{title}</h1>")
      table.push("<table border=\"1\">")
    end
    if row.to_s.match(/[A-z]/)
      if $output_format.match(/html/)
        row.each do |heading|
          table.push("<th>#{heading}</th>")
        end
      else
        if $output_format.match(/pipe/)
          title = "::"+title
          table = Terminal::Table.new :title => title, :style => { :border_x => "", :border_y => "", :border_i => "" }, :headings => row
        else
          table = Terminal::Table.new :title => title, :headings => row
        end
      end
    else
      if $output_format.match(/html/)
        table.push("<th>Item</th>")
        table.push("<th>Value</th>")
      else
        if $output_format.match(/pipe/)
          title = "::"+title
          table = Terminal::Table.new :title => title, :style => { :border_x => "", :border_y => "", :border_i => "" }, :headings => ['Item', 'Value']
        else
          table = Terminal::Table.new :title => title, :headings => ['Item', 'Value']
        end
      end
    end
  end
  if type.match(/end/)
    if $output_format.match(/html/)
      table.push("</table>")
      handle_output(table)
    else
      handle_output(table)
      handle_output("\n")
    end
  end
  if type.match(/line/)
    if !$output_format.match(/html/)
      table.add_separator
    end
  end
  if type.match(/row/)
    if $masked == 1
      if row.class == String 
        if title.match(/Serial|WWN|Domain|Name|Mount|[D,d]irectory|nvram|Customer|Contract|User|Email|Phone|Country|Host Name|Host ID|Volume|UUID|MAC|IP|Group|[T,t]ime|[D,d]ate/) and !$report_type.match(/kernel|module|modinfo|services|tcp|udp/)
          if !title.match(/Device Name|Vendor Name|Driver Name|Kernel/)
            row = "MASKED"
          end
        end
      else
        if row
          row.each.with_index do |value,index|
            if value.to_s.match(/[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]|[0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F]/) and !value.match(/sd\@|ssd|c[0-9]|_|pci/) and !$report_type.match(/kernel|module|modinfo|services|tcp|udp/)
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
      if value.to_s.match(/[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]|[0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F]/) and !value.match(/sd\@|ssd|c[0-9]|_|pci/) and !$report_type.match(/kernel|module|modinfo|services|tcp|udp/)
        $host_info[item] = "MASKED"
      else
        $host_info[item] = value
      end
    end
    if $output_format.match(/html/)
      table.push("<tr>")
      row.each do |value|
        if value.to_s.match(/[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]|[0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F]/) and !value.match(/sd\@|ssd|c[0-9]|_|pci/) and !$report_type.match(/kernel|module|modinfo|services|tcp|udp/)
          table.push("<td>MASKED</td>")
        else
          table.push("<td>#{value}</td>")
        end
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
