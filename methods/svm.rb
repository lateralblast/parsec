# SVM related code

# Get information from  md.cf

def get_md()
  file_name  = "/disks/svm/etc/lvm/md.cf"
  file_array = exp_file_to_array(file_name)
  return file_array 
end

# Get information from  md.cf

def get_mddb()
  file_name  = "/disks/svm/etc/lvm/mddb.cf"
  file_array = exp_file_to_array(file_name)
  return file_array 
end

# Process SVM insformation

def process_svm()
  process_mddb()
  process_md()
  return
end

# Process md config

def process_md()
  file_array = get_md()
  file_array = file_array.reject{|entry| entry.match(/^#/)}
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "Solaris Volume Manager Metadevice Configuration Information"
    row   = [ 'Metadevice', 'Type', 'Config', 'Components' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line    = line.chomp.gsub(/\s+$/,"")
      if !line.match(/^#/) and line.match(/^[a-z,0-9]/)
	      md_info = line.split(/\s+/)
	      md_dev  = md_info[0]
	      if line.match(/\-[a-z]/)
	      	md_type = md_info[1].gsub(/\-/,"")
	      	md_conf = md_info[-1]
	      	md_devs = md_info[2..-2].join(",")
	      else
	      	md_type = "s"
	      	md_conf = md_info[1..2].join(",")
	      	md_devs = md_info[3..-1].join(",")
	      end
	      row   = [ md_dev, md_type, md_conf, md_devs ]
	      table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No SVM information available"
  end
  return
end

# Process md config

def process_mddb()
  file_array = get_mddb()
  file_array = file_array.reject{|entry| entry.match(/^#/)}
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    title = "Solaris Volume Manager Metadevice Database Configuration Information"
    row   = [ 'Driver', 'Device', 'Disk Block Address', 'Disk ID', 'Checksum' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line    = line.chomp.gsub(/\s+$/,"")
      if !line.match(/^#/) and line.match(/^[a-z,0-9]/)
	      row   = line.split(/\s+/)
	      table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No SVM information available"
  end
  return
end