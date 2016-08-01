# Services related code

# Get service names

def process_service_deps()
  file_name  = "/sysconfig/svcs-l.out"
  file_array = exp_file_to_array(file_name)
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    deps   = ""
    fmri   = ""
    name   = ""
    title  = "Service Dependencies"
    row    = [ 'Service', 'Dependencies' ]
    table  = handle_table("title",title,row,"")
    file_array.each_with_index do |line,index|
      if line.match(/^fmri/)
        if index > 2
          row   = [ fmri, deps ]
          table = handle_table("row","",row,table)
          table = handle_table("line","",row,table)
        end
        fmri = line.split(/\s+/)[1]
        deps = ""
      end
      if line.match(/^name/)
        name = line.split(/\s+/)
        name = name[1..-1].join(" ")
      end
      if line.match(/^dep/)
        if deps.match(/[a-z]/)
          deps = deps+"\n"+line.split(/\s+/)[2]
        else
          deps = line.split(/\s+/)[2]
        end
      end
    end
    row   = [ fmri, deps ]
    table = handle_table("row","",row,table)
    table = handle_table("end","","",table)
  else
    handle_output("\n")
    handle_output("No service dependency information available")
  end
  return
end

# Get service names

def process_service_descs()
  file_name  = "/sysconfig/svcs-l.out"
  file_array = exp_file_to_array(file_name)
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    deps   = ""
    fmri   = ""
    name   = ""
    title  = "Service Description"
    row    = [ 'Service', 'Description' ]
    table  = handle_table("title",title,row,"")
    file_array.each_with_index do |line,index|
      if line.match(/^fmri/)
        if index > 2
          row   = [ fmri, name ]
          table = handle_table("row","",row,table)
        end
        fmri = line.split(/\s+/)[1]
        deps = ""
      end
      if line.match(/^name/)
        name = line.split(/\s+/)
        name = name[1..-1].join(" ")
      end
      if line.match(/^dep/)
        if deps.match(/[a-z]/)
          deps = deps+"\n"+line.split(/\s+/)[2]
        else
          deps = line.split(/\s+/)[2]
        end
      end
    end
    row   = [ fmri, name ]
    table = handle_table("row","",row,table)
    table = handle_table("end","","",table)
  else
    handle_output("\n")
    handle_output("No service description information available")
  end
  return
end

# Process services

def process_services()
  file_array = get_manifests_services()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    handle_output("\n")
    title = "Service Statuses"
    row   = [ 'Service', 'Status', 'Recommended', 'Complies' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line    = line.chomp
      items   = line.split(/\s+/)
      state   = items[0]
      service = items[4]
      if !service
        service = items[3]
        while service.match(/^[0-9]/)
          service = service.gsub(/^[0-9]/,"")
        end
      end
      if !service.match(/^[a-z]/)
        service = service[1..-1]
      end
      line = $manifest_services.select{|item| item.match(/^#{service}/)}
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
        row   = [service,curr_val,rec_val,complies]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    handle_output("\n")
    handle_output("No service manifest information available")
  end
  return
end
