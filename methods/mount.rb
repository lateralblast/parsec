# Mounts information

# Get mount information

def get_mounts()
  file_name = "/disks/mount.out"
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
      if line.match(/^\//)
        info    = line.split(/\s+/)
        mount   = info[0]
        source  = info[1]
        options = info[2]
        date    = info[3..-1].join(" ")
        row     = [ mount, options, ]
        table   = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
    puts
    title = "Mount Source Information"
    row   = [ 'Mount', 'Source', ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      line = line.gsub(/ on /," ")
      if line.match(/^\//)
        info    = line.split(/\s+/)
        mount   = info[0]
        source  = info[1]
        options = info[2]
        date    = info[3..-1].join(" ")
        row     = [ mount, source ]
        table   = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  end
  return
end