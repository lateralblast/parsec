# Mounts information

# Get mount information

def get_mounts()
  file_name = "/disks/mount-v.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process diskinfo insformation

def process_mounts()
  file_array = get_mounts()
  if file_array
    title = "Mount Options Information"
    row   = [ 'Mount', 'Options', ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      line = line.gsub(/ on /," ")
      info    = line.split(/\s+/)
      mount   = info[1]
      source  = info[0]
      options = info[4]
      date    = info[5..-1].join(" ")
      row     = [ mount, options, ]
      table   = handle_table("row","",row,table)
    end
    table = handle_table("end","","",table)
    puts
    title = "Mount Source Information"
    row   = [ 'Mount', 'Source', ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      line = line.gsub(/ on /," ")
      info    = line.split(/\s+/)
      mount   = info[1]
      source  = info[0]
      options = info[4]
      date    = info[5..-1].join(" ")
      row     = [ mount, source ]
      table   = handle_table("row","",row,table)
    end
    table = handle_table("end","","",table)
    puts
    title = "Mount Type Information"
    row   = [ 'Mount', 'Type', 'Date', ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      line = line.gsub(/ on /," ")
      info    = line.split(/\s+/)
      mount   = info[1]
      source  = info[0]
      type    = info[3]
      options = info[4]
      date    = info[5..-1].join(" ")
      row     = [ mount, type, date ]
      table   = handle_table("row","",row,table)
    end
    table = handle_table("end","","",table)
  end
  return
end