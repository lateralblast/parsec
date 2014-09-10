# Handle handbook

def process_handbook()
  model      = get_model_name()
  header     = get_handbook_header(model)
  html_files = Dir.entries($handbook_dir).grep(/#{header}[ ,\.]/)
  spec_file  = $handbook_dir+"/"+html_files.grep(/Specifications/)[0]
  list_file  = $handbook_dir+"/"+html_files.grep(/Components/)[0]
  info_file  = $handbook_dir+"/"+html_files.grep(/Systems/)[0]
  if info_file
    if File.exist?(info_file)
      table  = handle_table("title","System Support Information","","")
      doc    = Nokogiri::HTML(File.open(info_file))
      facts  = doc.css("table")[3]
      info   = facts.css("tr")[4..9]
      titles = info.css("b")
      titles.each_with_index do |title,index|
        title = title.text.gsub(/\n/,"").gsub(/\s+/," ").gsub(/\[tm\]/,"").gsub(/Operating Environment Versions/,"")
        text  = info[index].css("td")[1..-1].text
        url   = info[index].css("td a")
        if url.to_s.match(/http/)
          content = url.to_s.split(/"/)[1]
        else
          content = text.gsub(/\n/,",").gsub(/\*/,"").gsub(/\s+/," ").gsub(/^ ,\s+/,"").gsub(/\s+$/,"").gsub(/,$/,"")
        end
        table = handle_table("row",title,content,table)
      end
      table = handle_table("end","","",table)
      handle_output("\n")
    end
  end
  if spec_file
    if File.exist?(spec_file)
      doc    = Nokogiri::HTML(File.open(spec_file))
      facts  = doc.css("table")[3]
      info   = facts.css("tr")
      title  = ""
      items  = {}
      titles = []
      info.each do |node|
        if node.to_s.match(/name/)
          title = node.css("b").text.gsub(/\n/," ").gsub(/:/,"").gsub(/\s+/," ")
          titles.push(title)
          items[title] = []
        else
          if title
            if node.text.match(/[A-z]|[0-9]/)
              items[title].push(node.text)
            end
          end
        end
      end
      titles.each do |title|
        table = Terminal::Table.new :title => title, :headings => ['Item', 'Value']
        length = items[title].length
        items[title].each_with_index do |item,index|
          data   = item.split("\n")
          header = data[1].gsub(/^\s+/,"")
          first  = data[2].gsub(/^\s+/,"")
          if !first.match(/[A-z]|[0-9]/)
            first = data[3].gsub(/^\s+/,"")
            if !first.match(/[A-z]|[0-9]/)
              first = data[4].gsub(/^\s+/,"")
              info  = data[4..-1]
            else
              info = data[3..-1]
            end
          else
            info = data[2..-1]
          end
          if !header.match(/Slot #/)
            row = [header,first]
            table.add_row(row)
            info.each do |cell|
              cell = cell.gsub(/\n/," ").gsub(/^\s+/,"")
              if cell.match(/[0-9]|[A-z]/) and cell != first
                if header.match(/PCI Expansion/)
                  if !cell.match(/^Slot #$|^Physical$|^Electrical$|[0-9]$/)
                    row  = [ "", cell ]
                    table.add_row(row)
                  end
                else
                  row  = [ "", cell ]
                  table.add_row(row)
                end
              end
            end
            if index < length-1
              table.add_separator
            end
          end
        end
        handle_output(table)
        handle_output("\n")
        handle_output("\n")
      end
      handle_output("\n")
    end
  end
  if list_file
    if File.exist?(list_file)
      doc    = Nokogiri::HTML(File.open(list_file))
      tables = doc.css("table")
      title  = ""
      items  = {}
      titles = []
      notes  = []
      tables.each do |table|
        nodes = table.css("tr")
        nodes.each do |node|
          if node.to_s.match(/name/)
            title = node.css("a").text
            if !title.match(/Oracle System Handbook|Cancel|Table Legend/) and title.match(/[A-z]/)
              titles.push(title)
              items[title] = []
            end
          else
            if title
              if !title.match(/Oracle System Handbook|Cancel|Table Legend/) and title.match(/[A-z]/)
                node.css("td").each do |cell|
                  if !cell.text.match(/^Code$|^PreviousPart #$|^Manufacturing Part#$|^Description$/)
                    if !cell.to_s.match(/ssh_note|colspan|ssh_exp/)
                      if cell.to_s.match(/\<li\>/) and !cell.previous_element.to_s.match(/\<li\>/)
                        items[title].push("-")
                        items[title].push(cell.text)
                      else
                        items[title].push(cell.text)
                      end
                    else
                      if cell.to_s.match(/colspan/)
                        notes.push(cell.text)
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      titles.each do |title|
        table = Terminal::Table.new :title => title, :headings => ['Option Part', 'Manufacturing Part', 'Description', 'Previous Part']
        counter = 0
        row     = []
        items[title].each do |item|
          if !item.match(/^\[F\]/)
            item = item.gsub(/\n/,"")
            item = item.gsub(/^\s+|\s+$/,"")
            row.push(item)
            counter = counter+1
            if counter % 4 == 0
              table.add_row(row)
              row = []
            end
          end
        end
        handle_output(table)
        handle_output("\n")
        handle_output("\n")
      end
      if notes[0]
        notes.each do |note|
          if note.match(/^[0-9] |[0-9][0-9] /)
            note = note.gsub(/^\n/,"")
            handle_output("#{note}")
          end
        end
        handle_output("\n")
      end
    end
  end
  return
end