# LDOM related code

# Get available LDOM version

def get_avail_ldom_ver(model_name)
  avail_ldom = ""
  case model_name
  when /^T1|^T2/
    avail_ldom = "1.2"
  else
    avail_ldom = "3.1.1"
  end
  return avail_ldom
end

# Get LDOM version

def get_ldom_ver(model_name)
  ldom_ver = ""
  hcp_ver  = ""
  hmd_ver  = ""
  cfg_ver  = ""
  hyp_ver  = ""
  if model_name.match(/^T/)
    file_name  = "/sysconfig/ldm_-V.out"
    file_array = exp_file_to_array(file_name)
    file_array.each do |line|
      line = line.chomp
      case line
      when /Logical Domains Manager/
        ldom_ver = line.split(/\s+/)[4].chomp.gsub(/\)/,"")
      when /Hypervisor control protocol/
        hcp_ver = line.split(/\s+/)[5]
      when /Hypervisor MD/
        hmd_ver = line.split(/\s+/)[5]
      when /Hostconfig/
        cfg_ver = line.split(/\s+/)[5]
      when /Hypervisor\s+v/
        hyp_ver = line.split(/\s+/)[5]
      end
    end
  end
  return ldom_ver,hcp_ver,hmd_ver,cfg_ver,hyp_ver
end

# Process ldom version

def process_ldom_ver(table)
  model_name = get_model_name()
  if model_name.match(/^T/)
    (ldom_ver,hcp_ver,hmd_ver,cfg_ver,hyp_ver) = get_ldom_ver(model_name)
    table       = handle_output("row","Hypervisor Control Protocol Version",hcp_ver,table)
    table       = handle_output("row","Hypervisor MD Version",hmd_ver,table)
    table       = handle_output("row","Hostconfig Version",cfg_ver,table)
    table       = handle_output("row","Hypervisor Version",hyp_ver,table)
    table       = handle_output("row","Installed LDom Version",ldom_ver,table)
    avail_ldom  = get_avail_ldom_ver(model_name)
    latest_ldom = compare_ver(ldom_ver,avail_ldom)
    if latest_ldom == avail_ldom
      avail_ldom = avail_ldom+" (Newer)"
    end
    table = handle_output("row","Available LDom Version",avail_ldom,table)
  end
  return table
end

# Get Domain hostnames

def get_ldom_hosts()
  ldom_hosts = []
  file_array = get_ldom_info()
  file_array.each do |line|
    line = line.chomp
    if line.match(/^DOMAIN/)
      host_name = line.split(/\|/)[1].split(/\=/)[1]
      ldom_hosts.push(host_name)
    end
  end
  return ldom_hosts
end

# Get Domain information

def get_ldom_info()
  file_name  = "/sysconfig/ldm_list_-l_-p.out"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Proces Domain information

def process_logical_domains()
  table       = ""
  file_array  = get_ldom_info()
  counter     = 0
  output      = 0
  dom_count   = 0
  vol_count   = 0
  group_count = 0
  host_name   = ""
  mask_hosts  = {}
  mask_vols   = {}
  mask_groups = {}
  file_array.each do |line|
    line = line.chomp
    dom_info = line.split(/\|/)
    if dom_info[0] and line.match(/\|/)
      if dom_info[0].match(/^DOMAIN/)
        output = 1
        if counter != 0
          table = handle_output("end","","",table)
        end
        counter  = counter+1
        dom_name = dom_info[1].split(/\=/)[1]
        if $masked == 1
          host_name = dom_name
          dom_name  = "domain"+dom_count.to_s
        end
        title    = "Logical Domain "+dom_name
        row      = ['Domain Items','Value']
        table    = handle_output("title",title,row,"")
      else
        if dom_info[0].match(/^[A-Z]/) and dom_info[0].match(/^V/)
          table  = handle_output("line","","",table)
          item   = dom_info[0]
          value  = "Value"
          table  = handle_output("row",item,value,table)
          table  = handle_output("line","","",table)
        end
      end
      dom_info.each do |dom_value|
        if output == 1
          if dom_value.match(/\=/)
            (item,value) = dom_value.split(/\=/)
            if item == "name" and line.match(/^DOMAIN/)
              item = "Hostname"
            end
            item = item.capitalize
            item = item.gsub(/^Dev/,"Device")
            item = item.gsub(/^Vol/,"Volume")
            item = item.gsub(/^Uuid/,"UUID")
            item = item.gsub(/^Cons/,"Console Port")
            item = item.gsub(/^Mem/,"Memory")
            item = item.gsub(/^Mac-addr/,"MAC Address")
            item = item.gsub(/^Hostid/,"Host ID")
            item = item.gsub(/^Cpu-arch/,"CPU Architecture")
            item = item.gsub(/^Mtu/,"MTU")
            item = item.gsub(/^Ncpu/,"CPUs")
            item = item.gsub(/^Id/,"ID")
            item = item.gsub(/^Linkprop/,"Link Property")
            item = item.gsub(/^Cid/,"CPU ID")
            item = item.gsub(/^Mpgroup/,"MP Group")
            item = item.gsub(/^Cpuset/,"CPU Set")
            item = item.gsub(/^Softstate/,"Status")
            item = item.gsub(/^Port/,"Console Port")
            item = item.gsub(/^Nclients/,"Clients")
            item = item.gsub(/Net-dev/,"Network Device")
            item = item.gsub(/Nvramrc/,"NVRAMRC")
            if item == "Memory"
              value = value.to_i/(1024*1024)
              if value > 1024
                value = value.to_i/1024
                value = value.to_s+" GB"
              else
                value = value.to_s+" MB"
              end
            end
            if item == "NVRAMRC" and $masked == 1
              value = "cr"
            end
            if item == "MAC Address" and $masked == 1
              value = "XX:XX:XX:XX:XX:XX"
            end
            if item == "Host ID" and $masked == 1
              value = "XXXXXXXXXX"
            end
            if item == "UUID" and $masked == 1
              value = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
            end
            if item == "Volume" and $masked == 1
              vol_name  = value
              temp_name = "disk"+vol_count.to_s
              value = value.gsub(/#{vol_name}/,temp_name)
              if !mask_vols["#{vol_name}"]
                mask_vols["#{vol_name}"] = temp_name
                vol_count = vol_count+1
              end
            end
            if item == "Group" and $masked == 1
              group_name = value
              temp_name  = "group"+group_count.to_s
              value = value.gsub(/#{host_name}/,temp_name)
              if !mask_groups["#{group_name}"]
                mask_groups["#{group_name}"] = temp_name
                group_count = group_count+1
              end
            end
            if item == "Hostname" and $masked == 1
              temp_name = "domain"+dom_count.to_s
              host_name = value
              value     = value.gsub(/#{host_name}/,temp_name)
              if !mask_hosts["#{host_name}"]
                mask_hosts["#{host_name}"] = temp_name
                dom_count = dom_count+1
              end
            end
            if item == "Volume" and $masked == 1
              mask_vols.each do |vol_name, temp_name|
                if value.match(/#{vol_name}/)
                  value = value.gsub(/#{vol_name}/,temp_name)
                end
              end
            end
            if item == "Group" and $masked == 1
              mask_groups.each do |group_name, temp_name|
                if value.match(/#{group_name}/)
                  value = value.gsub(/#{group_name}/,temp_name)
                end
              end
            end
            table = handle_output("row",item,value,table)
          end
        end
      end
    else
      if !line.match(/^VERSION|^VCPU|^MEMORY/)
        output = 1
        table  = handle_output("line","","",table)
        if line.match(/^IO|^MAU/)
          item   = line
        else
          item   = line.downcase.capitalize
        end
        value  = "Value"
        table  = handle_output("row",item,value,table)
        table  = handle_output("line","","",table)
      else
        output = 0
      end
    end
  end
  table = handle_output("end","","",table)
  return
end

# Process LDOM information

def process_ldom_info()
  model_name = get_model_name()
  if model_name.match(/^T/)
    title   = "LDom Information"
    row     = ['Item','Value']
    table   = handle_output("title",title,row,"")
    table   = process_ldom_ver(table)
    counter = 0
    ldom_hosts = get_ldom_hosts()
    ldom_hosts.each do |ldom_host|
      ldom_no = "Domain "+counter.to_s
      counter = counter+1
      if $masked == 1
        ldom_host = ldom_no.downcase.gsub(/ /,"")
      end
      table   = handle_output("row",ldom_no,ldom_host,table)
    end
    table = handle_output("end","","",table)
    process_logical_domains()
  end
  return
end
