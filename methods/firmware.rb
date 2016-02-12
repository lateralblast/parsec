# Firmware related code

def get_fw_info()
  file_name  = "/sysconfig/fwupdate_list_all.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def process_firmware()
  file_array = get_fw_info()
  table = ""
  check = 0
  if file_array.to_s.match(/[0-9]|[A-Z]|[a-z]/)
    file_array.each do |line|
      if line.match(/^SP/)
        title = "System SP/BIOS Firmware Information"
        row   = [ 'ID', 'Product Name', 'ILOM Version', 'BIOS/OBP Version', 'XML Support' ]
        table = handle_table("title",title,row,"")
      end
      if line.match(/^CONTROLLER/) and check == 0
        title = "Controller Firmware Information"
        row   = [ 'ID', 'Type', 'Manufacturer', 'Model', 'Product Name', 'FW Version', 'BIOS Version', 'EFI Version', 'FCODE Version', 'Package Version', 'NVDATA Version', 'XML Support' ]
        table = handle_table("title",title,row,"")
        check = 1
      end
      if line.match(/^sp/)
        row   = line.split(/ \s+/)
        table = handle_table("row","",row,table)
        table = handle_table("end","","",table)
      end
      if line.match(/^c[0-9]/)
        line  = line.split(//)
        left  = line[0..63].join.split(/ \s+/)
        left1 = left[0..3]
        left2 = left[4..-1].join(" ")
        left  = left1
        left.push(left2)
        right = line[64..-1].join.split(/ \s+/)
        if right.length < 7
          row = left + right[0..2]
          row.push("-")
          row = row + right[3..-1]
        else
          row = left + right
        end
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts "No firmware information available"
  end
  return
end
