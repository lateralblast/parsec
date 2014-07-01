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

# Process LDOM information

def process_ldom_info()
  model_name = get_model_name()
  if model_name.match(/^T/)
    title = "LDom Information"
    row   = ['Item','Value']
    table = handle_output("title",title,row,"")
    table = process_ldom_ver(table)
    table = handle_output("end","","",table)
  end
  return
end
