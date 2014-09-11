# List facters

def list_facters()
  counter = 0
  if File.directory?($fact_dir) or File.symlink?($fact_dir)
    fact_list=Dir.entries($fact_dir).sort
    if fact_list.to_s.match(/[A-z]/)
      title = "Facters in "+$fact_dir+":"
      table = Terminal::Table.new :title => title, :headings => ['Hostname', 'Date', 'File']
      fact_list.each do |fact_file|
        if fact_file.match(/[A-z]/)
          file_name = $fact_dir+"/"+fact_file
          host_name = %x[cat #{file_name} |grep ^hostname |awk '{ print $3}']
          date_info = File.mtime(file_name)
          table_row = [ host_name, date_info, fact_file ]
          table.add_row(table_row)
        end
      end
      handle_output(table)
      handle_output("\n")
    end
  end
  return
end

def handle_facter_item(item)
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

def process_facter_configs(config)
  config.each do |title,facts|
    if title.match(/os/)
      table_title = title.upcase
    else
      table_title = title.capitalize
    end
    table = Terminal::Table.new :title => table_title, :headings => [ 'Item', 'Value' ]
    previous = ""
    headers = [ 'kernel', 'swap', 'hardware', 'operatingsystem', 'product', 'memory' ]
    length = facts.length
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
          item = handle_facter_item(item)
          row  = [item, value]
          table.add_row(row)
          temp  = header
        end
      end
      if found != 1
        if item.match(/_/) and !item.match(/^mtu|^ipaddress|^macaddress/)
          item    = item.split(/_/)[1..-1].join(" ")
        end
        item = handle_facter_item(item)
        row  = [item, value]
        table.add_row(row)
        if current != previous and index < length-1
          table.add_separator
        end
      end
      previous = current
    end
    puts table
    puts
  end
end

def process_facter(host_name,file_name)
  if file_name.match(/[A-z]/)
    if !File.exist?(file_name)
      puts "Facter file: "+file_name+" does not exist"
    end
  else
    file_name = %x[grep -l "hostname => #{host_name}" #{$fact_dir}/*].split("\n")[0]
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
    process_facter_configs(config)
  else
    puts "Facter file does not exist for host: "+host_name
  end
end