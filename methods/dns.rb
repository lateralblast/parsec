# DNS related code

# Get DNS information

def get_dns_info()
  file_name  = "/etc/resolv.conf"
  file_array = exp_file_to_array(file_name)
  return file_array
end

# Get Domain

def get_dns_domain()
  dns_info   = get_dns_info()
  dns_domain = dns_info.grep(/^domain/).join.gsub(/\n/,'').gsub(/domain /,' ').gsub(/^ /,'')
  return dns_domain
end

# Get Name Server

def get_dns_server()
  dns_info   = get_dns_info()
  dns_server = dns_info.grep(/^nameserver/).join.gsub(/\n/,'').gsub(/nameserver /,' ').gsub(/^ /,'')
  return dns_server
end

# Get DNS Search

def get_dns_search()
  dns_info   = get_dns_info()
  dns_search = dns_info.grep(/^search/).join.gsub(/\n/,'').gsub(/search /,' ').gsub(/^ /,'')
  return dns_search
end

# Process DNS information

def process_dns_info(table)
  dns_domain = get_dns_domain()
  dns_server = get_dns_server()
  dns_search = get_dns_search()
  if $masked == 0
    table = handle_output("row","Domain",dns_domain,table)
    table = handle_output("row","Name Server(s)",dns_server,table)
    table = handle_output("row","Search Domain(s)",dns_search,table)
  else
    table = handle_output("row","Domain","domain",table)
    table = handle_output("row","Name Server(s)","nameserver",table)
    table = handle_output("row","Search Domain(s)","search",table)
  end
  return table
end
