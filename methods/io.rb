# IO related code

# Get IO information

def get_io_info()
  io_info = search_prtdiag_info("IO Devices")
  return io_info
end

# Process IO information

def process_io_info()
  table     = handle_output("title","IO Information","","")
  io_info   = get_io_info()
  counter   = 0
  io_count  = 0
  sys_model = get_sys_model()
  io_length = io_info.select{|line| line.match(/^[0-9]|^pci/)}.length
  io_info.each do |line|
    #puts line
    counter = counter+1
    if line.match(/^[0-9]|^pci/)
      io_count     = io_count+1
      io_line      = line.chomp
      io_line      = line.split(/\s+/)
      sys_board_no = io_line[0]
      if sys_model.match(/M[3-9]0/)
        table   = handle_output("row","IOU",sys_board_no,table)
        io_type = io_line[1]
      else
        io_type  = io_line[0]
        io_speed = io_line[1]
        table    = handle_output("row","Speed",io_speed,table)
        io_type  = io_line[0]
      end
      table   = handle_output("row","Type",io_type,table)
      io_name = io_line[-1]
      table   = handle_output("row","Name",io_name,table)
      io_path = io_info[counter]
      io_path = io_path.to_s
      io_path = io_path.gsub(/\s+/,'')
      io_path = io_path.gsub(/okay/,'')
      table   = handle_output("row","Path",io_path,table)
      if sys_model.match(/M[3-9]0/)
        io_slot = get_io_slot(io_path,io_type,sys_model)
      else
        io_slot = io_line[2]
      end
      table   = handle_output("row","Slot",io_slot,table)
      ctlr_no = get_ctlr_no(io_path)
      if ctlr_no.match(/[0-9]/)
        table = handle_output("row","Controller",ctlr_no,table)
      end
      (dev_name,drv_name,inst_no) = process_drv_info(io_path)
      table = handle_output("row","Driver",drv_name,table)
      table = handle_output("row","Instance",inst_no,table)
      if io_path.match(/network/)
        port_no   = io_path[-1]
        table     = handle_output("row","Port",port_no,table)
        aggr_name = process_aggr_info(dev_name)
        if aggr_name.match(/[A-z]/)
          table = handle_output("row","Aggregate",aggr_name,table)
          if_hostname = get_if_hostname(aggr_name)
        else
          if_name = drv_name+inst_no
          if $masked == 0
            table = handle_output("row","Interface",if_name,table)
          else
            table = handle_output("row","Interface","xxxxxxxx",table)
          end
          if_hostname = get_if_hostname(if_name)
        end
        if if_hostname.match(/[A-z]/)
          if $masked == 0
            table = handle_output("row","Hostname",if_hostname,table)
          else
            table = handle_output("row","Hostname","xxxxxxxx",table)
          end
          if_ip = get_hostname_ip(if_hostname)
          if if_ip
            if $masked == 0
              table = handle_output("row","IP",if_ip,table)
            else
              table = handle_output("row","IP","XXX.XXX.XXX.XXX",table)
            end
          end
        end
      end
      table = process_ctlr_info(table,io_name,io_path,ctlr_no)
    end
    if line.match(/^[0-9]|^pci/) and io_count != io_length-2
      table = handle_output("line","","",table)
    end
  end
  table = handle_output("end","","",table)
  return
end
