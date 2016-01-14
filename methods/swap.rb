# Swap information

# Get diskinfo information

def get_swap()
  file_name = "/disks/swap-l.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process diskinfo insformation

def process_swap()
  file_array = get_swap()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    source = ""
    title  = "Swap Information"
    row    = [ 'Swap File', 'Device', '512K Blocks / Page', 'Blocks', 'Free' ]
    table  = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if line.match(/^\//)
        row   = line.split(/\s+/)
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No swap information available"
  end
  return
end