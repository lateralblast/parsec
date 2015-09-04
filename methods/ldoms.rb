# LDOM related code

def set_param_name(item)
  item = item.gsub(/^cpu-arch/,"CPU Architecture")
  item = item.gsub(/^dev/,"Device")
  item = item.gsub(/^cpu/,"CPU")
  item = item.gsub(/name/,"Name")
  item = item.gsub(/^state/,"State")
  item = item.gsub(/^flags/,"Flags")
  item = item.gsub(/^uptime/,"Uptime")
  item = item.gsub(/^vol/,"Volume")
  item = item.gsub(/log/,"Log")
  item = item.gsub(/^Uuid/,"UUID")
  item = item.gsub(/^cons/,"Console Port")
  item = item.gsub(/^mem$/,"Memory")
  item = item.gsub(/^mac-addr/,"MAC Address")
  item = item.gsub(/^hostid/,"Host ID")
  item = item.gsub(/^mtu/,"MTU")
  item = item.gsub(/^ncpu/,"CPUs")
  item = item.gsub(/^uuid/,"UUID")
  item = item.gsub(/^vcpu/,"vCPU")
  item = item.gsub(/information/,"Information")
  item = item.gsub(/^id/,"ID")
  item = item.gsub(/^linkprop/,"Link Property")
  item = item.gsub(/^cid/,"CPU ID")
  item = item.gsub(/^vid/,"vCPU ID")
  item = item.gsub(/mpgroup/,"MP Group")
  item = item.gsub(/group/,"Group")
  item = item.gsub(/mode/,"Mode")
  item = item.gsub(/max-cores/,"Max Cores")
  item = item.gsub(/physical-bindings/,"Physical Bindings")
  item = item.gsub(/thread/,"Thread")
  item = item.gsub(/norm_/,"Normal ")
  item = item.gsub(/shutdown-/,"Shutdown ")
  item = item.gsub(/util/,"Utilisation")
  item = item.gsub(/master/,"Master")
  item = item.gsub(/^cpuset/,"CPU Set")
  item = item.gsub(/^softstate/,"Status")
  item = item.gsub(/^port/,"Console Port")
  item = item.gsub(/^nclients/,"Clients")
  item = item.gsub(/net-dev/,"Network Device")
  item = item.gsub(/timeout/,"Timeout")
  item = item.gsub(/server/,"Server")
  item = item.gsub(/service/,"Service")
  item = item.gsub(/failure-policy/,"Failure Policy")
  item = item.gsub(/extended-mapin-space/,"Extended Mapin Space")
  return item
end

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
    table       = handle_table("row","Hypervisor Control Protocol Version",hcp_ver,table)
    table       = handle_table("row","Hypervisor MD Version",hmd_ver,table)
    table       = handle_table("row","Hostconfig Version",cfg_ver,table)
    table       = handle_table("row","Hypervisor Version",hyp_ver,table)
    table       = handle_table("row","Installed LDom Version",ldom_ver,table)
    avail_ldom  = get_avail_ldom_ver(model_name)
    latest_ldom = compare_ver(ldom_ver,avail_ldom)
    if latest_ldom == avail_ldom
      avail_ldom = avail_ldom+" (Newer)"
    end
    table = handle_table("row","Available LDom Version",avail_ldom,table)
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

# Process M Series Logical Domain Information

def process_m_series_logical_domains()
  table = ""
  host  = ""
  param = ""
  file_array = get_ldom_info()
  if file_array
    ldom = Hash.new {|hash, key| hash[key] = Hash.new }
    file_array.each do |line|
      line  = line.chomp
      items = line.split(/\|/)
      case line
      when /^DOMAIN/
        host = items[1].split(/\=/)[1]
        if host
          items[2..-1].each do |item|
            (param,value)     = item.split(/\=/)
            param = set_param_name(param)
            ldom[host][param] = value
          end
        end
      when /^[A-Z]/
        if line.match(/\|/)
          if host
            items[1..-1].each do |item|
              (param,value)     = item.split(/\=/)
              if param == "name" or param == "group"
                param = items[0].capitalize+" Name"
              end
              if param.match(/alt-mac-add/)
                macs = value.split(/\,/)
                macs.each_with_index do |mac, index|
                  param = "Alternate MAC Address "+index.to_s
                  ldom[host][param] = mac
                end
              else
                param = set_param_name(param)
                ldom[host][param] = value
              end
            end
          end
        else
          param = line+" Information"
          param = set_param_name(param)
          ldom[host][param] = "" 
        end
      when /^\|/
        line  = line.gsub(/^\|/,"")
        if line.match(/\|/)
          param = items[1].gsub(/\=/," ")
          param = set_param_name(param)
          value = items[2..-1].join(", ")
        else
          param = set_param_name(param)
          (param,value) = line.split(/\=/)
        end
        param = set_param_name(param)
        ldom[host][param] = value
      else
      end
    end
    ldom.each do |host,details|
      title = "Logical Domain: "+host
      row   = [ "Domain Items", "Values" ]
      table = handle_table("title",title,row,"")
      details.each do |item,value|
        value = ldom[host][item]
        row   = [ item, value ]
        if item.match(/Information/)
          table = handle_table("line","","",table)
          table = handle_table("row","",row,table)
          table = handle_table("line","","",table)
        else
          if item.match(/^CPU$|^Vnet/)
            table = handle_table("line","","",table)
          end
          table = handle_table("row","",row,table)
        end
      end
      table = handle_table("end","","",table)
    end
  end
  return
end

# Process T Series Logical Domain information

def process_t_series_logical_domains()
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
          table = handle_table("end","","",table)
        end
        counter  = counter+1
        dom_name = dom_info[1].split(/\=/)[1]
        title    = "Logical Domain "+dom_name
        row      = ['Domain Items','Value']
        table    = handle_table("title",title,row,"")
      else
        if dom_info[0].match(/^[A-Z]/) and dom_info[0].match(/^V/)
          table  = handle_table("line","","",table)
          item   = dom_info[0]
          value  = "Value"
          if value
            table  = handle_table("row",item,value,table)
          end
          table  = handle_table("line","","",table)
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
            if value
              table = handle_table("row",item,value,table)
            end
          end
        end
      end
    else
      if !line.match(/^VERSION|^VCPU|^MEMORY/)
        output = 1
        table  = handle_table("line","","",table)
        if line.match(/^IO|^MAU/)
          item   = line
        else
          item   = line.downcase.capitalize
        end
        value  = "Value"
        if value
          table  = handle_table("row",item,value,table)
        end
        table  = handle_table("line","","",table)
      else
        output = 0
      end
    end
  end
  table = handle_table("end","","",table)
  return
end

# Process LDOM information

def process_ldom()
  model_name = get_model_name()
  if model_name.match(/^T|^M[5,6]-/)
    title   = "LDom Information"
    row     = ['Item','Value']
    table   = handle_table("title",title,row,"")
    table   = process_ldom_ver(table)
    counter = 0
    ldom_hosts = get_ldom_hosts()
    ldom_hosts.each do |ldom_host|
      ldom_no = "Domain "+counter.to_s
      counter = counter+1
      table   = handle_table("row",ldom_no,ldom_host,table)
    end
    table = handle_table("end","","",table)
    if model_name.match(/^T/)
      process_t_series_logical_domains()
    else
      process_m_series_logical_domains()
    end
  end
  return
end
