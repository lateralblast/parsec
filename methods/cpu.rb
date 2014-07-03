# CPU related code

# Get number of cores

def get_core_no()
  file_name  = "/sysconfig/uname-X.out"
  file_array = exp_file_to_array(file_name)
  core_no    = file_array.grep(/^NumCPU/)
  core_no    = core_no[0].to_s.split(" = ")
  core_no    = core_no[1]
  return core_no
end

# Process number of cores

def process_core_no(table)
  core_no = get_core_no()
  table   = handle_output("row","Cores",core_no,table)
  return table
end

# Get CPU information

def get_cpu_info()
  cpu_info = search_prtdiag_info("CPUs")
  return cpu_info
end

# Get CPU family

def get_cpu_type(cpu_id)
  no_zeros   = 8-cpu_id.length
  cpu_id     = "0"*no_zeros+cpu_id
  cpu_type   = ""
  file_name  = "/sysconfig/prtconf-vp.out"
  file_array = exp_file_to_array(file_name)
  file_array.each do |line|
    line.chomp
    if line.match(/compatible:/)
      if line.match(/SPARC/)
        cpu_type = line.split(": '")
        cpu_type = cpu_type[1]
        cpu_type = cpu_type.split(",")
        cpu_type = cpu_type[1]
        cpu_type = cpu_type.gsub("'","")
        cpu_mask = cpu_type[5]
      end
    end
    if line.match(/cpuid:/)
      if line.match(/#{cpu_id}/)
        return cpu_type
      end
    end
  end
end

# Process CPU information

def process_cpu_info()
  model_name   = get_model_name()
  thread_ratio = 1
  if model_name.match(/^M|^T/)
    case model_name
    when /T2|T3-|T5[0-9]/
      thread_ratio = 8
    when /T1|T4-|T5-/
      thread_ratio = 4
    end
    table = handle_output("title","Domain CPU Information","","")
  else
    table = handle_output("title","CPU Information","","")
  end
  cpu_info     = get_cpu_info()
  sys_model    = get_sys_model()
  length       = cpu_info.length
  counter      = 0
  thread_count = 0
  cpu_count    = 0
  cpu_info.each do |line|
    counter      = counter+1
    sys_board_no = "1"
    cpu_no       = ""
    if line.match(/[0-9][0-9]/)
      case sys_model
      when /T[0-9]/
        if line.match(/^[0-9]/)
          cpu_line   = line.split(/\s+/)
          cpu_thread = cpu_line[0]
          cpu_speed  = cpu_line[1..2].join(" ")
          cpu_type   = cpu_line[3]
          cpu_status = cpu_line[4]
        end
      when /V1/
        if line.match(/^ [0-9]/)
          cpu_line     = line.split(/\s+/)
          sys_board_no = cpu_line[1]
          cpu_no       = cpu_line[2]
          cpu_module   = cpu_line[3]
          cpu_speed    = cpu_line[4]+" MHz"
          cpu_cache    = cpu_line[5]
          cpu_mask     = cpu_line[7]
          cpu_type     = get_sys_model()
          cpu_list     = cpu_no
          cpu_type     = cpu_type.split(/\(/)[1].split(/ /)[0]
        end
      when /480R/
        if line.match(/^ [A-Z]/)
          cpu_line     = line.split(/\s+/)
          sys_board_no = cpu_line[1]
          cpu_no       = cpu_line[2]
          cpu_speed    = cpu_line[3]+" MHz"
          cpu_cache    = cpu_line[4]
          cpu_type     = cpu_line[5]
          cpu_mask     = cpu_line[6]
        end
      when /V4/
        if line.match(/^[0-9]/)
          cpu_line  = line.split(/\s+/)
          cpu_no    = cpu_line[0].to_s
          cpu_speed = cpu_line[1]+" MHz"
          cpu_cache = cpu_line[3]
          cpu_type  = cpu_line[4].split(/,/)[1]
          cpu_mask  = cpu_line[5]
          cpu_list  = "0"
        end
      when /M[3-9]0/
        if line.match(/^ [0-9]/)
          cpu_list     = ""
          cpu_line     = line.split(/\s+/)
          cpu_no       = cpu_line[2]
          cpu_mask     = cpu_line[-1]
          cpu_cache    = cpu_line[-3]
          cpu_speed    = cpu_line[-4]+" MHz"
          sys_board_no = cpu_line[1]
          cpu_ids      = line.split(/(?<=,)/)
          cpu_ids.each do |cpu_id|
            if cpu_id.match(/,$/)
              cpu_id = cpu_id.split(/\s+/)
              cpu_id = cpu_id[-1]
            else
              cpu_id = cpu_id.gsub(/^\s+/,"")
              cpu_id = cpu_id.split(/\s+/)
              cpu_id = cpu_id[0]
            end
            cpu_list = cpu_list+cpu_id
          end
          cpu_ids  = cpu_list.split(",")
          cpu_id   = cpu_ids[0]
          cpu_id   = cpu_id.to_i.chr.unpack('H*')
          cpu_id   = cpu_id[0]
          cpu_type = get_cpu_type(cpu_id)
    #     cpu_family=get_cpu_family(cpu_mask)
        end
      end
      table = handle_output("row","System Board",sys_board_no,table)
      if sys_model.match(/T[0-9]/)
        core_no = (thread_count / thread_ratio)
        if cpu_core
          table = handle_output("row","Core",core_no,table)
        end
        if cpu_thread
          table = handle_output("row","Thread",cpu_thread,table)
        end
        thread_count = thread_count+1
      end
      if cpu_module
        table = handle_output("row","Module",cpu_module,table)
      end
      if cpu_no
        table = handle_output("row","Socket",cpu_no,table)
      end
      if cpu_mask
        table = handle_output("row","Mask",cpu_mask,table)
      end
      if cpu_speed
        table = handle_output("row","Speed",cpu_speed,table)
      end
      if cpu_cache
        table = handle_output("row","Cache",cpu_cache,table)
      end
      if cpu_list
        table = handle_output("row","IDs",cpu_list,table)
      end
      if cpu_type
        table = handle_output("row","Type",cpu_type,table)
      end
      cpu_count = cpu_count+1
      if counter < length-1 and cpu_count >= 1
        table = handle_output("line","","",table)
      end
    end
  end
  table = handle_output("end","","",table)
  return
end
