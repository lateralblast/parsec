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
  install_cluster = install_cluster[0].split(/\=/)[1]
  if install_cluster
    table = handle_table("row","Install Cluster",install_cluster,table)
  end
  return table
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
    row   = ['Package','Version','Install']
    table = handle_table("title",title,row,"")
    file_array.each do |line|
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
      if prefix.match(/FILES/)
        if $masked == 1
          if !pkg_name.match(/^CSW|^SUNW|^splunk|^SMC|^SME|^FJ|^TSI|^VRTS|^SYM/)
            pkg_name = "MASKED"
          end
        end
        row   = [pkg_name,pkg_ver,pkg_date]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  end
  return
end
