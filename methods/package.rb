# Package related code

# Get install cluster

def get_install_cluster()
  file_name  = "/var/CLUSTER"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process install cluster

def process_install_cluster(table)
  install_cluster = get_install_cluster()
  if install_cluster[0]
    install_cluster = install_cluster[0].split(/\=/)[1]
    table = handle_table("row","Install Cluster",install_cluster,table)
  end
  return table
end

# Get package history

def get_pkg_history()
  file_name = "/patch+pkg/pkg_history.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process package history

def process_pkg_history()
  file_array = get_pkg_history()
  if file_array
    title = "Package History"
    row   = [ 'Operation', 'Client', 'Outcome', 'Date' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^START/)
        (pkg_date,pkg_operation,pkg_client,pkg_outcome) = line.split(/\s+/)
        row   = [ pkg_operation, pkg_client, pkg_outcome, pkg_date ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  end
  return
end

# Get package mediator

def get_pkg_mediator()
  file_name = "/patch+pkg/pkg_mediator.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process package mediator

def process_pkg_mediator()
  file_array = get_pkg_mediator()
  if file_array
    title = "Package Mediator"
    row   = [ 'Package', 'Source', 'Version', 'Implementation' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^MEDIATOR/)
        (pkg_name,pkg_source,pkg_version,pkg_implementation) = line.split(/\s+/)
        row   = [ pkg_name, pkg_source, pkg_version, pkg_implementation ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  end
  return
end

# Get package properties

def get_pkg_properties()
  file_name = "/patch+pkg/pkg_property.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process package properties

def process_pkg_properties()
  file_array = get_pkg_properties()
  if file_array
    title = "Package Properties"
    row   = [ 'Property', 'Value' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^PROPERTY/)
        pkg_info     = line.split(/\s+/)
        pkg_property = pkg_info[0]
        pkg_value    = pkg_info[1..-1].join(" ")
        row   = [ pkg_property, pkg_value ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  end
  return
end

# Get package publisher information

def get_pkg_publisher()
  file_name = "/patch+pkg/pkg_publisher.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Process package publisher information

def process_pkg_publisher()
  file_array = get_pkg_publisher()
  if file_array
    title = "Package Publisher"
    row   = [ 'Publisher', 'Type', 'Status', 'Location' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if !line.match(/^Listing|^==|^PUBLISHER/)
        if line.match(/[A-z]/)
          (pkg_publisher,pkg_type,pkg_status,pkg_flag,pkg_location) = line.split(/\s+/)
          row   = [ pkg_publisher, pkg_type, pkg_status, pkg_location ]
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  end
  return
end

# Process package info

def get_pkg_info()
  file_name  = "/patch+pkg/pkginfo-l.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

def process_packages()
  file_array = get_pkg_info()
  pkg_name   = ""
  pkg_ver    = ""
  pkg_date   = ""
  if file_array
    title = "Package Information"
    row   = [ 'Package', 'Version', 'Install' ]
    table = handle_table("title",title,row,"")
    file_array.each do |line|
      line = line.chomp
      if line.match(/:/)
        (prefix,info) = line.split(/: /)
        if prefix.match(/PKGINST/)
          pkg_name = info
        end
        if prefix.match(/VERSION/)
          pkg_ver = info
        end
        if prefix.match(/INSTDATE/)
          pkg_date = info
        end
        if prefix.match(/FILES|STATUS/)
          if $masked == 1
            if !pkg_name.match(/^CSW|^SUNW|^splunk|^SMC|^SME|^FJ|^TSI|^VRTS|^SYM|^TIV/)
              pkg_name = "MASKED"
            end
          end
          row   = [pkg_name,pkg_ver,pkg_date]
          table = handle_table("row","",row,table)
        end
      end
    end
    table = handle_table("end","","",table)
  end
  os_version = get_os_version()
  if os_version == "5.11"
    process_pkg_history()
    process_pkg_mediator()
    process_pkg_properties()
    process_pkg_publisher()
  end
  return
end
