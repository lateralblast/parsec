# Memory related code

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
  sys_mem = get_sys_mem()
  table   = handle_output("row","Memory",sys_mem,table)
  return table
end

# Get memory information

def get_mem_info
  mem_info=search_prtdiag_info("Memory Configuration")
  return mem_info
end

# Process Memory information

def process_mem_info()
  table     = handle_output("title","Memory Information","","")
  mem_info  = get_mem_info()
  sys_model = get_sys_model()
  mem_info.each do |line|
    if line.match(/[0-9][0-9]/)
      sys_board_no = "1"
      mem_line     = line.split(/\s+/)
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
      if mem_size
        table = handle_output("row","System Board",sys_board_no,table)
        table = handle_output("row","Group(s)",mem_group,table)
        table = handle_output("row","Size",mem_size,table)
        table = handle_output("row","Status",mem_status,table)
        table = handle_output("row","DIMMs",mem_dimms,table)
        table = handle_output("row","DIMM Size",mem_dimm_size,table)
        table = handle_output("row","Mirror",mem_mirror,table)
        table = handle_output("row","Interleave",mem_interleave,table)
      end
    end
  end
  table = handle_output("end","","",table)
  return
end


