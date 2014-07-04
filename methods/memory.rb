# Memory related code

# Get Total memory

def get_total_mem()
  file_name  = "/sysconfig/prtdiag-v.out"
  file_array = exp_file_to_array(file_name)
  total_mem  = file_array.grep(/^0x0/)[0].split(/\s+/)[1..2].join(" ")
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

# Process System Memory

def process_sys_mem(table)
  model_name = get_model_name()
  sys_mem    = get_sys_mem()
  if model_name.match(/^T/)
    total_mem = get_total_mem()
    table     = handle_output("row","Domain Memory",sys_mem,table)
    table     = handle_output("row","System Memory",total_mem,table)
  else
    table     = handle_output("row","Memory",sys_mem,table)
  end
  return table
end

# Get memory information

def get_mem_info
  mem_info=search_prtdiag_info("Memory Configuration")
  return mem_info
end

# Process Memory information

def process_mem_info()
  table          = handle_output("title","Memory Information","","")
  sys_model      = get_sys_model()
  sys_mem        = get_sys_mem()
  table          = handle_output("row","System Memory",sys_mem,table)
  if !sys_model.match(/V120/)
    table = handle_output("line","","",table)
  end
  mem_info       = get_mem_info()
  length         = mem_info.grep(/[0-9]/).length
  counter        = 0
  previous       = ""
  mem_interleave = ""
  mem_count      = 0
  total_mem      = ""
  dimm_size      = ""
  mem_info.each do |line|
    if line.match(/[0-9][0-9]|D[0-9]$/)
      counter       = counter+1
      sys_board_no  = "1"
      mem_line      = line.split(/\s+/)
      if sys_model.match(/T[0-9]/)
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
      if sys_model.match(/480R/)
        sys_board_no   = mem_line[1]
        mem_controller = mem_line[2]
        mem_bank       = mem_line[3]
        mem_size       = mem_line[4]
        mem_dimm_size  = mem_line[5]
        mem_interleave = mem_line[6]
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
      if mem_size or mem_group
        if sys_board_no
          table = handle_output("row","System Board",sys_board_no,table)
        end
        if mem_controller
          table = handle_output("row","Memory Controller",mem_controller,table)
        end
        if mem_bank
          table = handle_output("row","Memory Bank",mem_bank,table)
        end
        if mem_group
          table = handle_output("row","Group(s)",mem_group,table)
        end
        if mem_size
          table = handle_output("row","Size",mem_size,table)
        end
        if mem_status
          table = handle_output("row","Status",mem_status,table)
        end
        if mem_dimms
          table = handle_output("row","DIMMs",mem_dimms,table)
        end
        if mem_dimm_size
          table = handle_output("row","DIMM Size",mem_dimm_size,table)
        end
        if mem_mirror
          table = handle_output("row","Mirror",mem_mirror,table)
        end
        if mem_interleave
          table = handle_output("row","Interleave",mem_interleave,table)
        end
        mem_count = mem_count+1
        if counter < length and mem_count >= 1
          table = handle_output("line","","",table)
        end
        previous = line
      end
    end
  end
  table = handle_output("end","","",table)
  return
end


