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
      line = line.chomp
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
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No service dependency information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No service dependency information available\n")
    end
  end
  return table
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
      line = line.chomp
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
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No service description information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No service description information available\n")
    end
  end
  return table
end

# Process services

def process_services()
  table = []
  t_table = process_service_descs()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_service_status()
  if t_table.class == Array
    table = table + t_table
  end
  t_table = process_service_deps()
  if t_table.class == Array
    table = table + t_table
  end
  return table
end

def process_service_status()
  file_array = get_manifests_services()
  if file_array.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    handle_output("\n")
    title = "Service Statuses"
    if $nocheck == 0
      row = [ 'Service', 'Status', 'Recommended', 'Complies' ]
    else
      row = [ 'Service', 'Status', ]
    end
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
        if $nocheck == 0
          row = [ service, curr_val, rec_val, complies ]
        else
          row = [ service, curr_val ]
        end
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    if $output_format.match(/table|pipe|pdf/)
      handle_output("\n")
      handle_output("No service manifest information available\n")
    else
      table = ""
      table = handle_output("\n")
      table = handle_output("No service manifest information available\n")
    end
  end
  return table
end
