# Get PCI Scan

def get_pci_scan()
  file_name  = "/sysconfig/scanpci-v.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process PCI Scan

def process_pci()
  file_array = get_pci_scan()
  counter = 0
  if file_array.to_s.match(/[0-9]|[A-Z]|[a-z]/)
    title = "PCI Scan Information"
    row   = ['Item','Information']
    table = handle_table("title",title,row,"")
    file_array.each_with_index do |line,index|
      line = line.chomp
      pci_info = line.split(/\s+/)
      if line.match(/^pci bus/)
        counter = 0
        if index > 2
          table = handle_table("line","","",table)
        end
        pci_desc = file_array[index+1].chomp.gsub(/^\s+/,"")
        table    = handle_table("row","Description",pci_desc,table)
        table    = handle_table("row","PCI Bus",pci_info[2],table)
        table    = handle_table("row","Card Number",pci_info[4],table)
        table    = handle_table("row","Vendor",pci_info[8],table)
        table    = handle_table("row","Device",pci_info[10],table)
      end
      if line.match(/CardVendor/)
        table = handle_table("row","Card Vendor",pci_info[2],table)
        table = handle_table("row","Card",pci_info[4..-1].join(" "),table)
      end
      if line.match(/STATUS/)
        table = handle_table("row","Status",pci_info[2],table)
        table = handle_table("row","Command",pci_info[4],table)
      end
      if line.match(/CLASS/)
        table = handle_table("row","Class",pci_info[2..4].join(" "),table)
        table = handle_table("row","Revision",pci_info[6],table)
      end
      if line.match(/BIST/)
        table = handle_table("row","Built in Self Test",pci_info[2],table)
        table = handle_table("row","Header",pci_info[4],table)
        table = handle_table("row","Latency",pci_info[6],table)
        table = handle_table("row","Cache",pci_info[8],table)
      end
      if line.match(/MAX_LAT/)
        table = handle_table("row","Max Latency",pci_info[2],table)
        table = handle_table("row","Min Grant",pci_info[4],table)
        table = handle_table("row","Interupt PIN",pci_info[6],table)
        table = handle_table("row","Interupt Line",pci_info[8],table)
      end
      if line.match(/BASE/)
        table   = handle_table("row","Base "+counter.to_s,pci_info[2..-1].join(" "),table)
        counter = counter+1
      end
      if line.match(/:/) and !line.match(/^pci bus/)
        (item,value) = line.split(/:/)
        item  = item.gsub(/^\s+/,"")
        value = value.gsub(/^\s+/,"")
        table = handle_table("row",item,value,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No PCI scan information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No PCI scan information available\n")
    end
  end
  return table
end
