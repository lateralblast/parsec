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