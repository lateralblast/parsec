# FRU related code

# Get FRU information

def get_fru_info(model_name)
  fru_info = search_prtdiag_info("FRU Status")
  return fru_info
end

# Process FRU information

def process_fru()
  model_name = get_model_name()
  fru_info   = get_fru_info(model_name)
  if fru_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    length     = fru_info.grep(/^SYS/).length
    title      = "FRU Information"
    row        = [ 'Location', 'Name', 'Status' ]
    table = handle_table("title",title,row,"")
    fru_info.each do |line|
      if line.match(/^SYS/)
        line  = line.gsub(/Not present/,"not-present")
        row   = line.split(/\s+/)
        table = handle_table("row","",row,table)
      else
        if line.match(/SYS/)
          line = line.gsub(/^\s+/,"")
          location = "MB"
          (name,status) = line.split(/\s+/)
          row = [ location, name, status ]
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No FRU information available"
  end
  return
end
