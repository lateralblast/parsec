# Zone related code

# Process the Zone information.

def process_zones()
  table      = handle_table("title","Zone Information","","")
  file_name  = "/sysconfig/zoneadm-list-iv.out"
  file_array = exp_file_to_array(file_name)
  table = Terminal::Table.new :title => "Zone Information", :headings => [ 'ID', 'Name', 'Status', 'Path', 'Brand', 'IP' ]
  file_array.each do |line|
    if !line.match(/STATUS/)
      line = line.gsub(/^\s+/,"")
      row  = line.split(/\s+/)
      table.add_row(row)
    end
  end
  handle_output(table)
  handle_output("\n")
end

