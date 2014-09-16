# Secuirty related code

# Get cryptoadm information

def get_crypto_providers()
  file_name = "/crypto/cryptoadm_list_-p.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process cryptoadm insformation

def process_crypto_providers()
  file_array = get_crypto_providers()
  if file_array
    source = ""
    title  = "Crypto Providers"
    row    = [ 'Source', 'Library / Algorithm', 'Status' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^==/)
        if line.match(/^Kernel/)
          table = handle_table("line","","",table)
        end
        if line.match(/:$/)
          source = line.split(/\s+/)[0]
        end
        if line.match(/: [A-z]/)
          (library,status) = line.split(/: /)
          status = status.gsub(/\. /,"\n")
          row   = [ source, library, status ]
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  end
  return
end

# Get elfsign information

def get_elfsign()
  file_name = "/crypto/elfsign_verify.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process elfsign insformation

def process_elfsign()
  file_array = get_elfsign()
  if file_array
    source = ""
    title  = "Elfsign Verification"
    row    = [ 'Library / Algorithm', 'Status' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if line.match(/: [A-z]/)
        info    = line.split(/\s+/)
        status  = info[-1]
        library = info[3]
        row     = [ library, status ]
        table   = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  end
  return
end

# Get crypto list

def get_crypto_list()
  file_name = "/crypto/cryptoadm_list_-vm.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process

def process_crypto_list()
  file_array = get_crypto_list()
  table = ""
  if file_array
    file_array.each do |line|
      line = line.chomp
      if line.match(/[A-z]/) and !line.match(/^Slot|^Provider|^=/)
        if line.match(/:$/)
          if line.match(/Mechanisms/)
            table = handle_table("end","","",table)
            row   = [ "Mechanism Name", "Min", "Max", "H\nW", "E\nn\nc",
                      "D\ne\nc", "D\ni\ng", "S\ni\nn\ng", "S\ni\ng\n+\nR",
                      "V\ne\nr\ni", "V\ne\nr\ni\n+\nR", "K\ne\ny\nG\ne\nn",
                      "P\na\ni\nr\nG\ne\nn", "W\nr\na\np", "U\nn\nw\nr\na\np",
                      "D\ne\nr\ni\nv\ne", "E\nC\n\nC\na\np\ns" ]
          else
            row = [ 'Item', 'Value' ]
          end
          title = line.gsub(/:$/,"")
          table = handle_table("title",title,row,"")
        end
        if line.match(/: [A-z,0-9]/)
          (item,value) = line.split(/: /)
          value = value.gsub(/,/,",\n")
          row   = [ item, value ]
          table = handle_table("row","",row,table)
        else
          if line.match(/^CKM/)
            line = line.gsub(/_DH/,"_DH ")
            row = line.split(/\s+/)
          end
        end
      else
        if line.match(/^Slot #/)
          row = line.split(/\s+/)
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  end
  return
end

# Process Security (defaults)

def process_security(report_type)
  curr_name  = ""
  table      = ""
  row        = ""
  file_array = ""
  comment    = ""
  handle_output("")
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
          handle_output(table)
          handle_output("\n")
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
      handle_output(table)
      handle_output("\n")
    end
  end
  os_version = get_os_version
  if os_version == "5.11"
    process_crypto_providers()
    process_crypto_list()
    process_elfsign()
  end
  return
end
