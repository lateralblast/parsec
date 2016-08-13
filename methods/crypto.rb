# Crypto

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
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    file_array.each do |line|
      line = line.chomp
      if line.match(/[A-Z]|[a-z]|[0-9]/) and !line.match(/User-level/)
        if line.match(/Mechanisms:|providers:|Provider:/)
          if line.match(/Provider: \//)
            (prefix,suffix) = line.split(/\: /)
            suffix = File.basename(suffix)
            line   = prefix+" "+suffix
          end
          table = handle_table("end","","",table)
          if line.match(/Mechanisms/)
            row   = [ "Mechanism Name", "Min", "Max", "H\nW", "E\nn\nc",
                      "D\ne\nc", "D\ni\ng", "S\ni\nn\ng", "S\ni\ng\n+\nR",
                      "V\ne\nr\ni", "V\ne\nr\ni\n+\nR", "K\ne\ny\nG\ne\nn",
                      "P\na\ni\nr\nG\ne\nn", "W\nr\na\np", "U\nn\nw\nr\na\np",
                      "D\ne\nr\ni\nv\ne", "E\nC\n\nC\na\np\ns" ]
          else
            row = [ 'Item', 'Value' ]
          end
          title = line.gsub(/:/,"")
          table = handle_table("title",title,row,"")
        end
        if line.match(/^Kernel/)
          table = handle_table("title",title,row,"")
        end
        if line.match(/: [A-z,0-9]/) and !line.match(/rovider/)
          (item,value) = line.split(/: /)
          value = value.gsub(/,/,",\n")
          row   = [ item, value ]
          table = handle_table("row","",row,table)
        else
          if line.match(/^CKM/)
            if line.match(/DH[0-9][0-9]/)
              line  = line.gsub(/_DH/,"_DH ")
            end
            row   = line.split(/\s+/)
            table = handle_table("row","",row,table)
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
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No crypto information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No crypto information available\n")
    end
  end
  return table
end

# Get cryptoadm information

def get_crypto_providers()
  file_name = "/crypto/cryptoadm_list_-p.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process cryptoadm insformation

def process_crypto_providers()
  file_array = get_crypto_providers()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
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
  else
    if $output_format.match(/table|pipe/)
      handle_output("\n")
      handle_output("No crypto provider information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No crypto provider information available\n")
    end
  end
  return table
end

def process_crypto()
  if $output_format.match(/html|wiki/)
    table   = []
  end
  t_table = process_crypto_list()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_crypto_providers()
  if t_table.class == Array
    table = table + t_table
  end
  return table
end
