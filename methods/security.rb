# Secuirty related code

# Process Security (defaults)

def process_security(report_type)
  curr_name  = ""
  table      = ""
  row        = ""
  file_array = ""
  comment    = ""
  $defaults.each do |item|
    found      = 0
    items      = item.split(/,/)
    file_name  = items[0]
    param_name = items[1]
    spacer     = items[2]
    rec_val    = items[3]
    if report_type.match(/all|security/) or file_name.match(/#{report_type}/)
      if curr_name != file_name
        if curr_name != ""
          puts table
          puts
        end
        curr_name  = file_name
        title      = "Security Settings ("+file_name+")"
        table      = Terminal::Table.new :title => title, :headings => ['Item', 'Current','Recommended','Complies']
        file_array = exp_file_to_array(file_name)
        curr_name  = file_name
      end
      if file_array
        file_array.each do |line|
          line.chomp
          if line.match(/^#{param_name}/)
            curr_val = line.split(/#{spacer}/)[1]
            if curr_val
              curr_val = curr_val.gsub(/\s+/,'')
              found    = 1
              if curr_val == rec_val
                comment = "Yes"
              else
                comment = "*No*"
              end
              row = [param_name,curr_val,rec_val,comment]
              table.add_row(row)
            end
          end
        end
      end
      if found == 0
        curr_val = "N/A"
        comment  = "*No*"
        row      = [param_name,curr_val,rec_val,comment]
        table.add_row(row)
      end
    end
    if item == $defaults.last
      puts table
      puts
    end
  end
  return
end
