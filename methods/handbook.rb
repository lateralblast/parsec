# Handle handbook

# Handle handbook info file

def process_handbook_info_file(info_file)
  if File.exist?(info_file)
    doc    = Nokogiri::HTML(File.open(info_file))
    facts  = doc.css("table")[3]
    info   = facts.css("tr")[4..-1]
    title  = ""
    items  = {}
    titles = []
    info.each do |node|
      if node.to_s.match(/\<b\>[A-z]/) and !node.to_s.match(/Quick Facts/)
        title = node.css("b").text.gsub(/\n/,"").gsub(/\s+/," ").gsub(/\[tm\]/,"").gsub(/Operating Environment Versions/,"")
        titles.push(title)
        items[title] = []
        if title
          if node.to_s.match(/http/)
            url = node.css("a").to_s.split(/"/)[1]
            items[title].push(url)
          else
            text = node.css("td")[1..-1].text.gsub(/^\n/,"").gsub(/^\s+|\s+$/,"").gsub(/ \s+/," ").gsub(/Oracle /,"")

            items[title].push(text)
          end
        end
      end
    end
    table   = Terminal::Table.new :title => "Support Information", :headings => [ 'Item', 'Value' ]
    length  = titles.length
    index   = 0
    titles.each_with_index do |title,index|
      content = ""
      items[title].each do |item|
        content = items[title].join(" ")
      end
      row = [ title, content ]
      table.add_row(row)
      if index < length-1
        table.add_separator
      end
    end
    handle_output(table)
    handle_output("\n")
    handle_output("\n")
  end
  return
end

# Handle handbook spec file

def process_handbook_spec_file(spec_file)
  if File.exist?(spec_file)
    doc     = Nokogiri::HTML(File.open(spec_file))
    tables  = doc.css("table")
    title   = ""
    t_table = ""
    item    = ""
    value   = ""
    counter = 0
    tables.each do |table|
      if !table.to_s.match(/Oracle System Handbook|Current Systems|Former STK Products|EOL Systems|Components|General Info|Cancel/)
        rows  = table.css("td")
        rows.each do |row|
          t_row   = []
          if row.to_s.match(/name/) and row.to_s.match(/sshtablecaption/) and !row.to_s.match(/label[A-z]/)
            title = row.css("b").text.gsub(/\n/,"").gsub(/\s+/," ")
            if title.match(/[A-z]/)
              if t_table
                handle_output(t_table)
                handle_output("\n")
              end
              if title == "Rack Mounting" or title == "Power Supplies"
                t_table = Terminal::Table.new :title => title
              else
                t_table = Terminal::Table.new :title => title, :headings => [ 'Item', 'Value' ]
                counter = 0
              end
            end
          else
            if title
              if title.match(/[A-z]/)
                if row.to_s.match(/[A-z]/) and !row.to_s.match(/label[A-z]/)
                  text = row.text.gsub(/^\n|\t/,"").gsub(/\s+/," ").gsub(/^\s+/,"")
                  if !text.match(/^x4$|^x8$|^[0-9]$|^x16$/)
                    length = text.length
                    if length > 70
                      text = text.gsub(/(.{1,78})(\s+|\Z)/, "\\1\n")
                    end
                    if counter == 0
                      if !row.next_element.to_s.match(/[A-z]/) and title == "Rack Mounting" or title == "Power Supplies"
                        t_row = [ text ]
                        t_table.add_row(t_row)
                      else
                        item    = text
                        counter = 1
                      end
                    else
                      value   = text
                      counter = 0
                      t_row   = [ item, value ]
                      t_table.add_row(t_row)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if t_table
      handle_output(t_table)
      handle_output("\n")
    end
  end
  return
end

# Process handbook components file

def process_handbook_list_file(list_file)
  if File.exist?(list_file)
    doc     = Nokogiri::HTML(File.open(list_file))
    tables  = doc.css("table")
    title   = ""
    notes   = []
    t_table = ""
    tables.each do |table|
      rows = table.css("tr")
      rows.each do |row|
        counter = 0
        if row.to_s.match(/name/)
          title = row.css("a").text
          if !title.match(/Oracle System Handbook|Cancel|Table Legend|Exploded View/) and title.match(/[A-z]/)
            if t_table
              handle_output(t_table)
              handle_output("\n")
            end
            t_table = Terminal::Table.new :title => title, :headings => ['Option Part', 'Manufacturing Part', 'Description', 'Previous Part']
            counter = 0
          end
        else
          if title
            if !title.match(/Oracle System Handbook|Cancel|Table Legend|Exploded View/) and title.match(/[A-z]/)
              if !row.to_s.match(/Manufacturing Part#|Not Shown|Field Replaceable Unit/)
                t_row = []
                if counter > 1
                  if t_table
                    t_table.add_separator
                  end
                else
                  counter = counter + 1
                end
                supported   = "-"
                current     = "-"
                description = "-"
                previous    = "-"
                row.css("td").each do |cell|
                  case cell.to_s
                  when /ssh_supported|ssh_xop|ssh_expcode/
                    supported = cell.text.gsub(/\n/,"").gsub(/^\s+|\s+$/,"")
                  when /ssh_mfpart|ssh_exppart/
                    current = cell.text.gsub(/\n/,"").gsub(/^\s+|\s+$/,"")
                  when /ssh_desc|ssh_expdesc/
                    description = cell.text.gsub(/\n/,"").gsub(/^\s+|\s+$/,"")
                  when /ssh_pre/
                    previous = cell.text.gsub(/\n/,"").gsub(/^\s+|\s+$/,"")
                  when /ssh_note/
                    notes.push(cell.text)
                  end
                end
                if t_table
                  t_row = [ supported, current, description, previous ]
                  if t_row.to_s.match(/[0-9]/)
                    t_table.add_row(t_row)
                  end
                end
              else
                row.css("td").each do |cell|
                  case cell.to_s
                  when /ssh_note/
                    notes.push(cell.text)
                  end
                end
              end
            else
              row.css("td").each do |cell|
                case cell.to_s
                when /ssh_note/
                  notes.push(cell.text)
                end
              end
            end
          end
        end
      end
    end
    if t_table
      handle_output(t_table)
      handle_output("\n")
    end
    if notes[0]
      notes.each do |note|
        if note.match(/^[0-9] |[0-9][0-9] /)
          note   = note.gsub(/^\n/,"")
          length = note.length
          if length > 75
            note = note.gsub(/\. /,".\n")
          end
          length = note.length
          if length > 75
            note = note.gsub(/\, /,".\n")
          end
          handle_output(note)
        end
      end
      handle_output("\n")
    end
  end
  return
end

# Process handbook

def process_handbook()
  model      = get_model_name()
  header     = get_handbook_header(model)
  html_files = Dir.entries($handbook_dir).grep(/#{header}[ ,\.]/)
  spec_file  = $handbook_dir+"/"+html_files.grep(/Specifications/)[0]
  list_file  = $handbook_dir+"/"+html_files.grep(/Components/)[0]
  info_file  = $handbook_dir+"/"+html_files.grep(/Systems/)[0]
  process_handbook_info_file(info_file)
  process_handbook_spec_file(spec_file)
  process_handbook_list_file(list_file)
  return
end