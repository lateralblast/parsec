# Memory related code

# Get Total memory

def get_total_mem()
  file_name  = "/sysconfig/prtdiag-v.out"
  file_array = exp_file_to_array(file_name)
  total_mem  = file_array.grep(/^0x0/)[0]
  if total_mem
    total_mem = total_mem.split(/\s+/)[1..2].join(" ")
  else
    total_mem = get_sys_mem()
  end
  return total_mem
end

# Get the System memory

def get_sys_mem()
  file_name  = "/sysconfig/prtdiag-v.out"
  file_array = exp_file_to_array(file_name)
  sys_mem    = file_array.grep(/^Memory size:/)
  sys_mem    = sys_mem[0]
  sys_mem    = sys_mem.split(": ")
  sys_mem    = sys_mem[1]
  sys_mem    = sys_mem.chomp
  return sys_mem
end

# Get Actual Memory

def get_actual_mem()
  file_name  = "/sysconfig/prtdiag-v.out"
  file_array = exp_file_to_array(file_name)
  actual_mem = file_array.grep(/^0x0/)[0].split(/\s+/)[1..2].join(" ")
  return actual_mem
end

# Process System Memory

def process_sys_mem(table)
  model_name = get_model_name()
  sys_mem    = get_sys_mem()
  if model_name.match(/^T/)
    total_mem = get_total_mem()
    if sys_mem
      table = handle_table("row","Domain Memory",sys_mem,table)
    end
    if total_mem
      table = handle_table("row","System Memory",total_mem,table)
    end
  else
    if sys_mem
      table = handle_table("row","Memory",sys_mem,table)
    end
  end
  return table
end

# Get memory information

def get_mem_info
  mem_info=search_prtdiag_info("Memory Configuration")
  return mem_info
end

# Process Memory information

def process_memory()
  sys_model      = get_sys_model()
  sys_mem        = get_sys_mem()
  if sys_mem.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    table          = handle_table("title","Memory Information","","")
    if sys_mem and !sys_model.match(/M[5-7]-|T[5-7]-/)
      table = handle_table("row","System Memory",sys_mem,table)
    end
    if sys_model.match(/T3/)
      actual_mem = get_actual_mem()
      table     = handle_table("row","Actual Memory",actual_mem,table)
    end
    if !sys_model.match(/V120|M[5-7]-|T[5-7]-/)
      table = handle_table("line","","",table)
    end
    mem_info       = get_mem_info()
    length         = mem_info.grep(/[0-9]/).length
    base_length    = mem_info.grep(/^0x/).length
    counter        = 0
    previous       = ""
    mem_interleave = ""
    total_mem      = ""
    dimm_size      = ""
    mem_dimm_size  = ""
    mem_bank_size  = ""
    mem_base       = ""
    bank_size      = 0
    block_count    = 0
    mem_module     = ""
    mem_modules    = []
    mem_info.each_with_index do |line,index|
      if line.match(/[0-9][0-9]|D[0-9]$/)
        counter       = counter+1
        sys_board_no  = "1"
        mem_line      = line.split(/\s+/)
        if sys_model.match(/T[0-9]/) and !sys_model.match(/T[5-7]-/)
          mem_group = mem_line[-1]
          if sys_model.match(/T5[1,2][2,4]/)
            mem_dimms = "1"
          end
          if line.match(/^[0-9]/)
            total_mem      = mem_line[1]
            dimm_size      = total_mem.to_i/length
            mem_interleave = mem_line[3]
            mem_size       = dimm_size.to_s+" GB"
            mem_dimm_size  = dimm_size.to_s+" GB"
          else
            if line.match(/GB/)
              mem_size      = dimm_size.to_s+" GB"
              mem_dimm_size = dimm_size.to_s+" GB"
            else
              if line.match(/MB/)
                mem_group = mem_line[-1]
                if previous.match(/GB/)
                  mem_size      = dimm_size.to_s+" GB"
                  mem_dimm_size = dimm_size.to_s+" GB"
                else
                  mem_size      = dimm_size.to_s+" GB"
                  mem_dimm_size = dimm_size.to_s+" GB"
                end
              end
            end
          end
        end
        if sys_model.match(/M10-|M[5,6]-|T[6,7]-/)
          mem_controller = mem_line[-1]
          if line.match(/^0x/)
            if mem_module.match(/SYS/)
              dimm_size     = bank_size / mem_modules.length+1
              mem_dimm_size = dimm_size.to_s+" GB"
              table         = handle_table("row","Number of DIMMs",mem_modules.length.to_s,table)
              table         = handle_table("row","DIMM Size",mem_dimm_size,table)
              mem_modules.each do |mem_module|
                table      = handle_table("row","Module",mem_module,table)
              end
              table       = handle_table("line","","",table)
              mem_modules = []
            end
            mem_base       = mem_line[0]
            mem_size       = mem_line[1]+" "+mem_line[2]
            mem_interleave = mem_line[3]
            mem_bank_size  = mem_line[4]+" "+mem_line[5]
            bank_size      = mem_line[4].to_i
            mem_module     = mem_line[6]
            sys_info       = mem_module.split(/\//)
            mem_board      = sys_info[2].gsub(/PM/,"")
            cpu_board      = sys_info[3].gsub(/CM/,"")
            table          = handle_table("row","Bank Size",mem_bank_size,table)
            table          = handle_table("row","Processor Board",mem_board,table)
            table          = handle_table("row","CPU Module",cpu_board,table)
            table          = handle_table("row","Interleave",mem_interleave,table)
            mem_modules.push(mem_module)
          else
            mem_module = mem_line[1]
            mem_modules.push(mem_module)
          end
        end
        if sys_model.match(/480R/)
          sys_board_no   = mem_line[1]
          mem_controller = mem_line[2]
          mem_bank       = mem_line[3]
          mem_size       = mem_line[4]
          if mem_line[5].match(/no_status/)
            mem_dimm_size  = mem_line[6]
            mem_interleave = mem_line[7]
          else
            mem_dimm_size  = mem_line[5]
            mem_interleave = mem_line[6]
          end
        end
        if sys_model.match(/M[3-9]0/)
          sys_board_no   = mem_line[1]
          mem_group      = mem_line[2]
          mem_size       = mem_line[3]
          mem_status     = mem_line[4]
          mem_dimm_size  = mem_line[5]
          mem_dimms      = mem_line[6]
          mem_mirror     = mem_line[7]
          mem_interleave = mem_line[8]
        end
        if sys_model.match(/V4/)
          mem_status = "N/A"
          mem_mirror = "N/A"
          if line.match(/^0x/)
            mem_base       = mem_line[0]
            mem_group_no   = mem_line[0].split(/x/)[1]
            mem_group_no   = mem_group_no.gsub(/000000000/,'')
            mem_size       = mem_line[1]
            mem_interleave = mem_line[2]
            mem_dimms      = mem_line[4]
            mem_dimm_no    = mem_dimms.split(/,/)[0]
            if line.match(/^0x0/)
              mem_search=mem_dimms
            end
            file_name      = "/sysconfig/prtdiag-v.out"
            file_array     = exp_file_to_array(file_name)
            mem_dimm_size  = file_array.grep(/#{mem_search}/)
            mem_dimm_size  = mem_dimm_size.grep(/MB/)
            mem_dimm_size  = mem_dimm_size.grep(/^#{mem_dimm_no}/)[0].split(/\s+/)[3]
            mem_group      = file_array.grep(/C[0-9]\/P[0-9]/)
            mem_group      = mem_group.grep(/^#{mem_group_no}/)
            mem_group_list = ""
            mem_group.each do |mem_group_line|
              mem_list=mem_group_line.split(/\s+/)[2]
              if mem_group_list.match(/C/)
                mem_group_list = mem_group_list+" "+mem_list
              else
                mem_group_list = mem_list
              end
            end
            mem_group = mem_group_list
          end
        end
        if mem_size or mem_group and !sys_model.match(/T[6,7]-/)
          f_count = 0
          if sys_board_no
            table   = handle_table("row","System Board",sys_board_no,table)
            f_count = f_count+1
          end
          if mem_base
            table   = handle_table("row","Base Address",mem_base,table)
            f_count = f_count+1
          end
          if mem_controller
            table   = handle_table("row","Memory Controller",mem_controller,table)
            f_count = f_count+1
          end
          if mem_bank
            table   = handle_table("row","Memory Bank",mem_bank,table)
            f_count = f_count+1
          end
          if mem_group
            table   = handle_table("row","Group(s)",mem_group,table)
            f_count = f_count+1
          end
          if mem_size
            table   = handle_table("row","Size",mem_size,table)
            f_count = f_count+1
          end
          if mem_status
            table   = handle_table("row","Status",mem_status,table)
            f_count = f_count+1
          end
          if mem_dimms
            table   = handle_table("row","DIMMs",mem_dimms,table)
            f_count = f_count+1
          end
          if mem_dimm_size
            table   = handle_table("row","DIMM Size",mem_dimm_size,table)
            f_count = f_count+1
          end
          if mem_mirror
            table   = handle_table("row","Mirror",mem_mirror,table)
            f_count = f_count+1
          end
          if mem_interleave
            table   = handle_table("row","Interleave",mem_interleave,table)
            f_count = f_count+1
          end
          case sys_model
          when /M[5,6,7]-/
            if line.match(/^[0-9,A-F]x/)
              block_count = block_count+1
            end
            if block_count < base_length
              table = handle_table("line","","",table)
            end
          when /V440/
            if line.match(/^[0-9,A-F]x/)
              block_count = block_count+1
            end
            if block_count < base_length
              table = handle_table("line","","",table)
            end
          when /480R/
            if counter < length
              table = handle_table("line","","",table)
            end
          else
            if counter < length-f_count-1
              table = handle_table("line","","",table)
            end
          end
          previous = line
        end
      end
    end
    if sys_model.match(/M10-|M[5,6]-|T[6,7]-/)
      dimm_size     = bank_size / mem_modules.length+1
      mem_dimm_size = dimm_size.to_s+" GB"
      table         = handle_table("row","Number of DIMMs",mem_modules.length.to_s,table)
      table         = handle_table("row","DIMM Size",mem_dimm_size,table)
      mem_modules.each do |mem_module|
        table      = handle_table("row","Module",mem_module,table)
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No memory information available"
  end
  return
end
