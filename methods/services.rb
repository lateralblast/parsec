# Services related code

# Process services

def process_services()
  file_array = get_manifests_services()
  if file_array
    puts
    title = "Service"
    table = Terminal::Table.new :title => title, :headings => ['Service', 'Status','Recommended','Complies']
    file_array.each do |line|
      items   = line.split(/\s+/)
      state   = items[0]
      service = items[4]
      line    = $manifest_services.select{|item| item.match(/^#{service}/)}
      if service.match(/^lrc/)
        type = "Legacy"
      else
        type = "Manifest"
      end
      if state.match(/legacy_run|online/)
        curr_val = "Enabled"
      end
      if state.match(/disabled/)
        curr_val = "Disabled"
      end
      if state.match(/maintenance/)
        curr_val = "Maintenance"
      end
      if line.to_s.match(/#{service}/)
        rec_val = "Disabled"
        if curr_val == rec_val
          complies = "Yes"
        else
          complies = "*No*"
        end
      else
        rec_val  = "N/A"
        complies = "N/A"
      end
      if !service.match(/FMRI/)
        row = [service,curr_val,rec_val,complies]
        table.add_row(row)
      end
    end
  end
  handle_output(table)
  handle_output("\n")
  return
end
