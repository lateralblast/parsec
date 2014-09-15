# Parse dmidecode output

# List dmidecode output

def list_dmidecodes()
  counter = 0
  if File.directory?($decode_dir) or File.symlink?($decode_dir)
    decode_list=Dir.entries($decode_dir).sort
    if decode_list.to_s.match(/[A-z]/)
      title = "DMI decodes in "+$decode_dir+":"
      table = Terminal::Table.new :title => title, :headings => [ 'Hostname', 'Date', 'File' ]
      decode_list.each do |decode_file|
        if decode_file.match(/[A-z]/)
          file_name = $decode_dir+"/"+decode_file
          host_name = File.basename(file_name).split(/\./)[0]
          if host_name.match(/[A-z]/)
            date_info = File.mtime(file_name)
            table_row = [ host_name, date_info, decode_file ]
            table.add_row(table_row)
          end
        end
      end
      handle_output(table)
      handle_output("\n")
    end
  end
  return
end

# Process Ansible Facts

def process_dmidecode(host_name,file_name)
  if file_name.match(/[A-z]/)
    if !File.exist?(file_name)
      puts "DMI decode file: "+file_name+" does not exist"
      exit
    end
  else
    file_name = Dir.entries($decode_dir).grep(/#{host_name}/)[0]
  end
  if !file_name
    puts "Could not find Ansible Fact file for host: "+host_name
    exit
  end
  if file.exists?(file_name)
    titles = []
    items  = {}
    values = {}
    lines  = IO.readline(file_name)
    lines.each_with_index do |line,index|
      line = line.chomp.gsub(/\s+$/,"")
      if line.match(/[A-z]|[0-9]/)
        if line.match(/^Handle/)
          title = lines[index+1].chomp.gsub(/\s+$/,"")
          titles.push(title)
          if !items[title]
            items[title] = []
          end
        else
          if line.match(/:$/)
            item  = line.gsub(/^\s+/,"").split(":")[0]
            array = 1
            items[title].push(item)
            values[item] = []
          else
            if line.match(/:/)
              (item,value) = line.gsub(/^\s+|\s+$/,"").split(": ")
              array = 0
              items[title].push(item)
              values[item].push(value)
            else
              if array = 1
                values[item].push(value)
              end
            end
          end
        end
      end
    end
    titles = titles.uniq
    title.each do |title|
    table = Terminal::Table.new :title => title, :headings => [ 'Item', 'Value' ]
    end
  end
  return
end