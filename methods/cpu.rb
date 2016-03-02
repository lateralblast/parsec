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
  table   = handle_table("row","Cores",core_no,table)
  return table
end

# Get general CPU info

def get_general_cpu_info()
  file_name  = "/sysconfig/prtdiag-v.out"
  file_array = exp_file_to_array(file_name)
  cpu_info   = file_array.grep(/CPU/)[0]
  if cpu_info
    cpu_info = cpu_info.chomp
  else
    cpu_info = ""
  end
  return cpu_info
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

def process_cpu()
  model_name = get_model_name()
  t_ratio    = 1
  c_ratio    = 1
  handle_output("\n")
  if model_name.match(/^M|^T/)
    case model_name
    when /T2|T3-|T5[0-9]/
      t_ratio = 8
    when /T1|T4-|T5-/
      t_ratio = 4
    when /M10-/
      t_ratio = 2
      c_ratio = 16
    end
    title = "Domain CPU Information"
  else
    title = "CPU Information"
  end
  cpu_info = get_cpu_info()
  if !cpu_info.to_s.match(/[0-9]/)
    table    = handle_table("title",title,"","")
    cpu_info = get_general_cpu_info()
    table    = handle_table("row","CPU",cpu_info,table)
    table    = handle_table("end","","",table)
    return
  end
  if cpu_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    row        = [ 'Bo.', 'Mo.', 'So.', 'Co.', 'Th.', 'Status', 'Speed', 'Mask', 'Cache', 'Type', 'IDs' ]
    table      = handle_table("title",title,row,"")
    sys_model  = get_sys_model()
    length     = cpu_info.length
    t_count    = 0
    board_no   = "1"
    cpu_module = ""
    cpu_no     = "1"
    core_no    = ""
    cpu_thread = ""
    cpu_status = ""
    cpu_speed  = ""
    cpu_mask   = ""
    cp_cache   = ""
    cpu_type   = ""
    cpu_ids    = ""
    cpu_info.each do |line|
      if line.match(/[0-9][0-9]/)
        cpu_line = line.split(/\s+/)
        case sys_model
        when /T[0-9]|M10-|M[5,6,7]-/
          if line.match(/^[0-9]/)
            cpu_thread = cpu_line[0]
            cpu_speed  = cpu_line[1..2].join(" ")
            cpu_type   = cpu_line[3]
            cpu_status = cpu_line[4]
          end
          if line.match(/^M/)
            board_no   = cpu_line[0]
            cpu_thread = cpu_line[1]
            cpu_speed  = cpu_line[2..3].join(" ")
            cpu_type   = cpu_line[4]
          end
        when /V1/
          if line.match(/^ [0-9]/)
            board_no   = cpu_line[1]
            cpu_no     = cpu_line[2]
            cpu_module = cpu_line[3]
            cpu_speed  = cpu_line[4]+" MHz"
            cpu_cache  = cpu_line[5]
            cpu_mask   = cpu_line[7]
            cpu_type   = get_sys_model()
            cpu_list   = cpu_no
            cpu_type   = cpu_type.split(/\(/)[1].split(/ /)[0]
          end
        when /480R|V490/
          if line.match(/^ [A-Z]/)
            board_no  = cpu_line[1]
            cpu_no    = cpu_line[2]
            cpu_speed = cpu_line[3]+" MHz"
            cpu_cache = cpu_line[4]
            cpu_type  = cpu_line[5]
            cpu_mask  = cpu_line[6]
          end
        when /V4/
          if line.match(/^[0-9]/)
            cpu_no    = cpu_line[0].to_s
            cpu_speed = cpu_line[1]+" MHz"
            cpu_cache = cpu_line[3]
            cpu_type  = cpu_line[4].split(/,/)[1]
            cpu_mask  = cpu_line[5]
            cpu_list  = "0"
          end
        when /M[3-9]0/
          if line.match(/^ [0-9]/)
            cpu_list  = ""
            cpu_no    = cpu_line[2]
            cpu_mask  = cpu_line[-1]
            cpu_cache = cpu_line[-3]
            cpu_speed = cpu_line[-4]+" MHz"
            board_no  = cpu_line[1]
            cpu_ids   = line.split(/(?<=,)/)
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
          end
        end
        if sys_model.match(/T[0-9]|M10-/) 
          if !sys_model.match(/T200/)
            cpu_no  = (t_count / c_ratio)
          end
          core_no = (t_count / t_ratio)
          t_count = t_count+1
        end
        row   = [ board_no, cpu_module, cpu_no, core_no, cpu_thread, cpu_status, cpu_speed, cpu_mask, cpu_cache, cpu_type, cpu_ids ]
        table = handle_table("row","",row,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No CPU information available"
  end
  return
end
