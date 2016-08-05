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

# List of reports

# I've used pushes here so it's easier to comment out one when debugging

def get_full_report_list()
  report_list = []
  report_list.push("host")
  report_list.push("inetadm")
  report_list.push("syslog")
  report_list.push("cups")
  report_list.push("obp")
  report_list.push("eeprom")
  report_list.push("cpu")
  report_list.push("memory")
  report_list.push("hardware")
  report_list.push("coreadm")
  report_list.push("dumpadm")
  report_list.push("explorer")
  report_list.push("disk")
  report_list.push("io")
  report_list.push("swap")
  report_list.push("vnic")
  report_list.push("link")
  report_list.push("zones")
  report_list.push("filesystem")
  report_list.push("services")
  report_list.push("liveupgrade")
  report_list.push("beadm")
  report_list.push("locale")
  report_list.push("modules")
  report_list.push("packages")
  report_list.push("patches")
  report_list.push("tcp")
  report_list.push("udp")
  report_list.push("ldom")
  report_list.push("domain")
  report_list.push("fru")
  report_list.push("sensors")
  #report_list.push("handbook")
  report_list.push("veritas")
  report_list.push("aggr")
  report_list.push("network")
  report_list.push("serials")
  report_list.push("firmware")
  report_list.push("ipmi")
  report_list.push("slots")
  report_list.push("pci")
  report_list.push("svm")
  report_list.push("ntp")
  report_list.push("pam")
  report_list.push("elfsign")
  report_list.push("system")
  report_list.push("passwd")
  report_list.push("login")
  report_list.push("sendmail")
  report_list.push("inetinit")
  report_list.push("su")
  report_list.push("inet")
  report_list.push("cron")
  report_list.push("keyserv")
  report_list.push("telnet")
  report_list.push("power")
  report_list.push("suspend")
  report_list.push("ssh")
  report_list.push("crypto")
  report_list.push("snmp")
  report_list.push("cups")
  report_list.push("ip")
  report_list.push("tcp")
  report_list.push("udp")
  report_list.push("arp")
  report_list.push("icmp")
  report_list.push("sctp")
  return report_list
end

# get list of reports

def get_report_list()
  report_list = []
  case $report_type
  when /,/
    full_report_list = get_full_report_list() 
    test_report_list = $report_type.split(/,/)
    full_report_text = full_report_list.join(",")
    test_report_list.each do |test_report|
      if full_report_text.match(/,#{test_report},/)
        report_list.push(test_report)
      end
    end
  when /^all$/
    report_list = get_full_report_list()
  when /security/
    report_list = []
    report_list.push("ntp")
    report_list.push("pam")
    report_list.push("elfsign")
    report_list.push("system")
    report_list.push("passwd")
    report_list.push("login")
    report_list.push("sendmail")
    report_list.push("inetinit")
    report_list.push("su")
    report_list.push("inet")
    report_list.push("cron")
    report_list.push("keyserv")
    report_list.push("telnet")
    report_list.push("power")
    report_list.push("suspend")
    report_list.push("ssh")
    report_list.push("crypto")
    report_list.push("snmp")
    report_list.push("cups")
    report_list.push("crypto")
  when /^os$/
    report_list.push("hardware")
    report_list.push("coreadm")
    report_list.push("dumpadm")
    report_list.push("explorer")
  when /kernel|ndd/
    report_list.push("system")
    report_list.push("ip")
    report_list.push("tcp")
    report_list.push("udp")
    report_list.push("arp")
    report_list.push("icmp")
    report_list.push("sctp")
  when /sds|svm|disksuite/
    report_list = [ "svm" ]
  else
    report_list = [ $report_type ]
  end
  return report_list
end

# Do configuration report

def config_report(report,host_name)
  report_list = get_report_list()
  full_report = []
  valid_sw    = 0
  if $output_format.match(/html/)
    handle_output("<html>")
    handle_output("<head>")
    handle_output("<title>Explorer report for #{host_name}</title>")
    handle_output("</head>")
    handle_output("<body>")
  end
  report_list.each do |report_name|
    valid_sw = 1
    t_report = eval"[process_#{report_name}]"
    if t_report
      if t_report.class == Array
        full_report = full_report + t_report
      end
    end
  end
  if $output_format.match(/html/)
    handle_output("</body>")
    handle_output("</html>")
  end
  handle_output("\n")
  if valid_sw == 0
    report_help(report)
    handle_output("\n")
  end
  return full_report
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
  if $output_file.match(/[0-9]|[A-Z]|[a-z]/)
    file = File.open($output_file,"a")
    if $output_format.match(/html|wiki/)
      if output.class == Array
        outut = output.join
      end
      file.write(output)
    else
      file.write(output)
    end
    file.write("\n")
    file.close()
  else
    if $output_format.match(/wiki/)
      if output.class == String
        puts output
      else
        output.each do |line|
          print line
        end
      end
    end
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
        if output.match(/[0-9]|[A-Z]|[a-z]/) 
          if output.match(/\</)
            puts "#{output}"
          else
            puts "<p>#{output}</p>"
          end
        end
      else
        puts "<p>"
        output.each do |line|
          if line.match(/[0-9]|[A-Z]|[a-z]/)
            puts "#{line}"
          end
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
    if $output_format.match(/wiki/)
      table = []
      table.push("%TABLE{ sort=\"on\" tableborder=\"0\" cellborder=\"0\" }%\n")
      table.push("|*#{title}*|\n|")
    end
    if row.to_s.match(/[0-9]|[A-Z]|[a-z]/)
      if $output_format.match(/wiki|html/)
        row.each do |heading|
          if $output_format.match(/html/)
            table.push("<th>#{heading}</th>")
          else
            table.push("#{heading}|")
          end
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
      if $output_format.match(/html|wiki/)
        if $output_format.match(/html/)
          table.push("<th>Item</th>")
          table.push("<th>Value</th>")
        end
        if $output_format.match(/wiki/)
          table.push("Item|Value|")
        end
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
    if !$output_format.match(/html|wiki/)
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
    if title.match(/[0-9]|[A-Z]|[a-z]/)
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
    if $output_format.match(/html|wiki/)
      if $output_format.match(/html/)
        table.push("<tr>")
      else
        table.push("\n|")
      end
      row.each do |value|
        if value.to_s.match(/[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]|[0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F][0-9,a-f,A-F]/) and !value.match(/sd\@|ssd|c[0-9]|_|pci/) and !$report_type.match(/kernel|module|modinfo|services|tcp|udp/)
          if $output_format.match(/html/)
            table.push("<td>MASKED</td>")
          else
            table.push("MASKED|")
          end
        else
          if $output_format.match(/html|wiki/)
            if $output_format.match(/html/)
              table.push("<td>#{value}</td>")
            else
              table.push("#{value}|")
            end
          end
        end
      end
      if $output_format.match(/html/)
        table.push("</tr>")
      end
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
