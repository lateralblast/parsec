# List facters

def list_facters()
  counter = 0
  if File.directory?($fact_dir) or File.symlink?($fact_dir)
    fact_list=Dir.entries($fact_dir).sort
    if fact_list.to_s.match(/[A-Z]|[a-z]|[0-9]/)
      title = "Puppet Facters in "+$fact_dir+":"
      row   = ['Hostname', 'Date', 'File']
      table = handle_table("title",title,row,"")
      fact_list.each do |fact_file|
        if fact_file.match(/[A-z]/)
          file_name = $fact_dir+"/"+fact_file
          host_name = %x[cat #{file_name} |grep ^hostname |awk '{ print $3}'].chomp
          if host_name.match(/[A-z]/)
            date_info = File.mtime(file_name)
            table_row = [ host_name, date_info, fact_file ]
            table     = handle_table("row","",table_row,table)
          end
        end
      end
      table = handle_table("end","","",table)
      title = "Ansible Facters in "+$fact_dir+":"
      row   = ['Hostname', 'Date', 'File']
      table = handle_table("title",title,row,"")
      fact_list.each do |fact_file|
        if fact_file.match(/[A-z]/)
          file_name = $fact_dir+"/"+fact_file
          host_name = %x[cat #{file_name} |grep ansible_hostname |cut -f2 -d:].chomp.gsub(/ |"|,/,"")
          if host_name.match(/[A-z]/)
            date_info = File.mtime(file_name)
            table_row = [ host_name, date_info, fact_file ]
            table     = handle_table("row","",table_row,table)
          end
        end
      end
      table = handle_table("end","","",table)
    else
      if !$output_file.match(/[A-z]/)
        puts
        puts "No facter information available"
      end
    end
  end
  return
end

# Handle Puppet Fact names/items

def handle_puppet_facter_item(item)
  strings = [ 'version', 'sitedir', 'address', 'release', 'system' ]
  strings.each do |string|
    if item.match(/[A-z]#{string}/)
      content = item.split(/#{string}/)
      if content[1]
        item = content[0]+" "+string+" "+content[1..-1].join(" ")
      else
        item = content[0]+" "+string
      end
    end
  end
  item = item.gsub(/_/," ")
  strings = [ 'os', 'isa', 'smc', 'l2', 'l3', 'vm', 'fqdn', 'cpu', 'mb', 'ip', 'mac', 'mtu', 'rom', 'uuid' ]
  contents = item.split(/ /)
  if !contents[1]
    contents[0] = item
  end
  copy = contents
  contents.each_with_index do |content,index|
    strings.each do |string|
      replace = string.upcase
      case content
      when /^#{string}$/
        content = content.gsub(/#{string}/,replace)
        copy[index] = content
      end
    end
    if !content.match(/[A-Z]/) and !content.match(/[0-9]/)
      copy[index] = content.capitalize
    end
  end
  item = copy.join(" ")
  return item
end

# Process each of the Puppet Facts

def process_puppet_facter_configs(config)
  config.each do |title,facts|
    if title.match(/os/)
      table_title = title.upcase
    else
      table_title = title.capitalize
    end
    row      = [ 'Item', 'Value' ]
    table    = handle_table("title",table_title,row,"")
    previous = ""
    headers  = [ 'kernel', 'swap', 'hardware', 'operatingsystem', 'product', 'memory' ]
    length   = facts.length
    facts.each_with_index do |fact,index|
      found = 0
      item  = ""
      (current,value) = fact.split(/ => /)
      item = current
      headers.each do |header|
        if item.match(/^#{header}/)
          found = 1
          if item.match(/^#{header}$/)
            item = header
          else
            item  = item.split(/#{header}/)[1]
          end
          item  = handle_puppet_facter_item(item)
          row   = [item, value]
          table = handle_table("row","",row,table)
          temp  = header
        end
      end
      if found != 1
        if item.match(/_/) and !item.match(/^mtu|^ipaddress|^macaddress/)
          item    = item.split(/_/)[1..-1].join(" ")
        end
        item  = handle_puppet_facter_item(item)
        row   = [item, value]
        table = handle_table("row","",row,table)
        if current != previous and index < length-1
          table = handle_table("line","","",table)
        end
      end
      previous = current
    end
    table = handle_table("end","","",table)
  end
end

# Process Puppet Fact file

def process_puppet_facter(host_name,file_name)
  if file_name.match(/[A-z]/)
    if !File.exist?(file_name)
      puts "Puppet Fact file: "+file_name+" does not exist"
      exit
    end
  else
    file_name = %x[grep -l "hostname => #{host_name}" #{$fact_dir}/*].split("\n")[0]
  end
  if !file_name
    puts "Could not find Puppet Fact file for host: "+host_name
    exit
  end
  if File.exist?(file_name)
    facts  = IO.readlines(file_name)
    config = {}
    config["host"]     = []
    config["os"]       = []
    config["network"]  = []
    config["hardware"] = []
    config["memory"]   = []
    config["kernel"]   = []
    config["software"] = []
    facts.each do |fact|
      if !fact.match(/\=\>[0-9,A-z,"]/)
        fact = fact.chomp
        case fact
        when /^arch|^hardware|^processor/
          config["hardware"].push(fact)
        when /^network|^mtu|^macaddress|^ipaddress/
          config["network"].push(fact)
        when /^sp_|^fqdn|^hostname|^productname/
          config["host"].push(fact)
        when /^macosx|^operatingsystem/
          config["os"].push(fact)
        when /^kernel/
          config["kernel"].push(fact)
        when /^memory/
          config["memory"].push(fact)
        when /^ruby|^puppet|^facter/
          config["software"].push(fact)
        end
      end
    end
    process_puppet_facter_configs(config)
  else
    if !$output_file.match(/[A-z]/)
      puts "Facter file does not exist for host: "+host_name
    end
  end
end

# Handle facter item

def process_ansible_item(item)
  item    = item.gsub(/addresses/,"address").gsub(/ipv/,"IPv")
  strings = [ 'version', 'sitedir', 'address', 'release', 'system' ]
  strings.each do |string|
    if item.match(/[A-z]#{string}/)
      content = item.split(/#{string}/)
      if content[1]
        item = content[0]+" "+string+" "+content[1..-1].join(" ")
      else
        item = content[0]+" "+string
      end
    end
  end
  item = item.gsub(/_/," ")
  if item.match(/^ansible|^facter/)
    contents = item.split(/ /)[1..-1]
  else
    contents = item.split(/ /)
  end
  strings  = [ 'os', 'isa', 'smc', 'l2', 'l3', 'vm', 'fqdn', 'cpu', 'mb', 'ip', 'mac', 'mtu', 'rom', 'uuid', 'path', 'osx', 'sp' ]
  copy     = contents
  contents.each_with_index do |content,index|
    strings.each do |string|
      replace = string.upcase
      case content
      when /^#{string}$/
        content = content.gsub(/#{string}/,replace)
        copy[index] = content
      end
    end
    if !content.match(/[A-Z]/) and !content.match(/[0-9]/)
      copy[index] = content.capitalize
    end
  end
  item = copy.join(" ")
  item = item.gsub(/^\s+|\s+$/,"")
  return item
end


# Process Ansible Facts

def process_ansible_facter(host_name,file_name)
  if file_name.match(/[A-z]/)
    if !File.exist?(file_name)
      puts "Ansible Fact file: "+file_name+" does not exist"
      exit
    end
  else
    file_name = %x[grep -l '"ansible_hostname": "#{host_name}"' #{$fact_dir}/*].split("\n")[0]
  end
  if !file_name
    puts "Could not find Ansible Fact file for host: "+host_name
    exit
  end
  if File.exist?(file_name)
    info   = {}
    lines  = IO.readlines(file_name)
    values = []
    array  = 0
    type   = ""
    item   = ""
    info["network"] = []
    info["system"]  = []
    lines.each_with_index do |line,index|
      if !line.match(/\{\}|\[\]|key|rsa|dsa/) and line.match(/[0-9]|[A-z]/)
        line = line.chomp
        if line.match(/": /)
          item = line.split(/"/)[1].gsub(/\s+/,"")
          item = process_ansible_item(item)
        end
        if line.match(/ansible|facter/) and !line.match(/ansible_facts/)
          if item.match(/[0-9]/)
            type = "network"
          else
            type = "system"
          end
        end
        if type.match(/[A-z]/)
          if line.match(/\{$|\[$/)
            value = ""
            row   = item+","+value
            info[type].push(row)
            if line.match(/\[$/)
              array  = 1
              values = []
            end
          else
            if array == 1
              value = line.gsub(/"|,/,"")
              values.push(value)
              if lines[index+1].match(/\],/)
                value = values.join(" ").gsub(/\s+/," ").gsub(/^\s+|\s+$/,"")
                if value.length > 70
                  value = value.gsub(/ /,"\n")
                end
                array = 0
                row   = item+", "+value
                info[type].push(row)
              end
            else
              if !line.match(/\],$/)
                if line.match(/": /) and item != "Changed"
                  value = line.split(/"/)[3]
                  if value
                    value = value.gsub(/"|,/,"")
                    value = value.gsub(/\s+/,"").gsub(/^\s+|\s+$/,"")
                    if item.match(/path|PATH/)
                      value = value.gsub(/:/,":\n")
                    end
                    if value.length > 70
                      value = value.gsub(/ /,"\n")
                    end
                    row   = item+","+value
                    info[type].push(row)
                  end
                end
              end
            end
          end
        end
      end
    end
    title  = "System Information"
    row    = [ 'Item', 'Value' ]
    table  = handle_table("title",title,row,"")
    length = info["system"].length
    info["system"].each_with_index do |line,index|
      (item,value) = line.split(",")
      if value
        value = value.gsub(/^\s+|^ /,"")
        row   = [ item, value ]
        table = handle_table("row","",row,table)
        if index < length-1
          table = handle_table("line","","",table)
        end
      end
    end
    table  = handle_table("end","","",table)
    title  = "Network Information"
    row    = [ 'Item', 'Value' ]
    table  = handle_table("title",title,row,"")
    length = info["network"].length
    info["network"].each_with_index do |line,index|
      (item,value) = line.split(",")
      if item.match(/Device|[0-9]/) and value
        value = value.gsub(/^\s+|^ /,"")
        if index > 1
          table = handle_table("line","","",table)
        end
        row   = [ item, value ]
        table = handle_table("row","",row,table)
        if item.match(/Device/)
          if index < length-1
            table = handle_table("line","","",table)
          end
        end
      else
        if value
          value = value.gsub(/^\s+|^ /,"")
          row   = [ item, value ]
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  end
  return
end
