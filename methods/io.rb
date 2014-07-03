# IO related code

# Get IO path

def get_io_path(io_device,counter)
  file_name  = "/etc/path_to_inst"
  file_array = exp_file_to_array(file_name)
  io_path    = file_array.grep(/"#{io_device}"/)[counter].split(/ /)[0].gsub(/"/,"")
  return io_path
end

# Get IO information

def get_io_info()
  model_name = get_model_name()
  case model_name
  when /T2/
    io_info = search_prtdiag_info("IO Configuration")
  when /V1/
    io_info = search_prtdiag_info("IO Cards")
  else
    io_info = search_prtdiag_info("IO Devices")
  end
  return io_info
end

# Some example M5000 output

=begin
    IO                                                Lane/Frq
LSB Type  LPID   RvID,DvID,VnID       BDF       State Act,  Max   Name                           Model
--- ----- ----   ------------------   --------- ----- ----------- ------------------------------ --------------------
    Logical Path
    ------------
00  PCIe  0      bc, 8532, 10b5       2,  0,  0  okay     8,    8  pci-pciexclass,060400          N/A
    /pci@0,600000/pci@0

00  PCIe  0      bc, 8532, 10b5       3,  8,  0  okay     8,    8  pci-pciexclass,060400          N/A
    /pci@0,600000/pci@0/pci@8

00  PCIe  0      bc, 8532, 10b5       3,  9,  0  okay     4,    8  pci-pciexclass,060400          N/A
    /pci@0,600000/pci@0/pci@9

00  PCIx  0       8,  125, 1033       4,  0,  0  okay   100,  133  pci-pciexclass,060400          N/A
    /pci@0,600000/pci@0/pci@8/pci@0

00  PCIx  0       8,  125, 1033       4,  0,  1  okay    --,  133  pci-pciexclass,060400          N/A
    /pci@0,600000/pci@0/pci@8/pci@0,1

00  PCIx  0       2,   50, 1000       5,  1,  0  okay    --,  133  scsi-pci1000,50                LSI,1064
    /pci@0,600000/pci@0/pci@8/pci@0/scsi@1
=end

# Some example T3-1 output

=begin
/SYS/MB/SASHBA0   PCIE  scsi-pciex1000,72                 LSI,2008     5.0GTx8
                        /pci@400/pci@1/pci@0/pci@4/scsi@0
/SYS/MB/SASHBA1   PCIE  scsi-pciex1000,72                 LSI,2008     5.0GTx8
                        /pci@400/pci@2/pci@0/pci@4/scsi@0
/SYS/MB/NET0      PCIE  network-pciex8086,10c9                         2.5GTx4
                        /pci@400/pci@2/pci@0/pci@6/network@0
/SYS/MB/NET1      PCIE  network-pciex8086,10c9                         2.5GTx4
                        /pci@400/pci@2/pci@0/pci@6/network@0,1
/SYS/MB/NET2      PCIE  network-pciex8086,10c9                         2.5GTx4
                        /pci@400/pci@2/pci@0/pci@7/network@0
/SYS/MB/NET3      PCIE  network-pciex8086,10c9                         2.5GTx4
                        /pci@400/pci@2/pci@0/pci@7/network@0,1
/SYS/MB/RISER0/PCIE3PCIE  SUNW,qlc-pciex1077,2532           QLE2562      5.0GTx4
                        /pci@400/pci@2/pci@0/pci@c/SUNW,qlc@0
/SYS/MB/RISER0/PCIE3PCIE  SUNW,qlc-pciex1077,2532           QLE2562      5.0GTx4
                        /pci@400/pci@2/pci@0/pci@c/SUNW,qlc@0,1
/SYS/MB/VIDEO     PCIX  display-pci1a03,2000                           --
                        /pci@400/pci@2/pci@0/pci@0/pci@0/display@0
/SYS/MB/PCIE-IO/USBPCIX  usb-pciclass,0c0310                            --
                        /pci@400/pci@2/pci@0/pci@f/pci@0/usb@0
/SYS/MB/PCIE-IO/USBPCIX  usb-pciclass,0c0310                            --
                        /pci@400/pci@2/pci@0/pci@f/pci@0/usb@0,1
/SYS/MB/PCIE-IO/USBPCIX  usb-pciclass,0c0320                            --
                        /pci@400/pci@2/pci@0/pci@f/pci@0/usb@0,2
=end

# Process IO information

def process_io_info()
  model_name = get_model_name()
  table      = handle_output("title","IO Information","","")
  io_info    = get_io_info()
  counter    = 0
  io_count   = 0
  sys_model  = get_sys_model()
  length     = io_info.length
  dev_count  = {}
  io_info.each do |line|
    counter = counter+1
    if line.match(/^[0-9]|^pci|^MB|^\/SYS|^IOBD|PCI/)
      # Fixed squashed output
      line         = line.gsub(/PCIE3PCIE/,"PCIE3 PCI3")
      line         = line.gsub(/USBPCIX/,"USB PCIX")
      io_count     = io_count+1
      io_line      = line.chomp
      io_line      = line.split(/\s+/)
      sys_board_no = io_line[0]
      case sys_model
      when /T[0-9]/
        io_slot = io_line[0]
      when /V1/
        sys_board_no = io_line[1]
        io_type      = io_line[2]
        io_speed     = io_line[3]+" MHz"
        io_slot      = io_line[4]
        io_path      = io_line[5]
        if line.match(/network|scsi|qlc|emlx/)
          io_name = io_line[-1]
        end
        if io_path.match(/glm|fc/)
          device     = io_path.split(/\-/)[1]
          if !dev_count[device]
            temp_count = 0
            dev_count[device] = temp_count+1
          else
            temp_count = dev_count[device]
            dev_count[device] = temp_count+1
          end
          io_path = get_io_path(device,temp_count)
        end
        if io_path.match(/network/)
          device    = io_name.split(/\-/)[1]
          if !dev_count[device]
            temp_count = 0
            dev_count[device] = temp_count+1
          else
            temp_count = dev_count[device]
            dev_count[device] = temp_count+1
          end
          io_path = get_io_path(device,temp_count)
        end
      when /M[3-9]0/
        io_name = io_line[-1]
        table   = handle_output("row","IOU",sys_board_no,table)
        io_type = io_line[1]
        io_slot = get_io_slot(io_path,io_type,sys_model)
      when /T[3-5]-/
        io_type  = io_line[1].gsub(/PCI3/,"PCIE")
        io_speed = io_line[-1]
        sys_board_no = io_line[0].split(/\//)[2]
        if line.match(/LSI|qlc|emlx/)
          io_name = io_line[-2]
        else
          io_name = "N/A"
        end
      when /T5[0-9]/
        io_type = io_line[1].gsub(/PCI3/,"PCIE")
        io_slot = io_line[0]
        if line.match(/LSI|qlc|emlx/)
          io_name = io_line[-1]
          if io_name.match(/Tx/)
            io_name  = io_line[-2]
            io_speed = io_line[-1]
          end
        else
          io_name = "N/A"
        end
        sys_board_no = io_line[0].split(/\//)[0]
      when /T2/
        io_type = io_line[1]
        io_slot = io_line[0]
        if line.match(/LSI|qlc|emlx/)
          io_name = io_line[-1]
          if io_name.match(/[0-9]LP/)
            io_name = io_name.split(/LP/)[1]
            io_name = "LP"+io_name
          end
        else
          io_name = "N/A"
        end
      else
        io_type  = io_line[0]
        io_speed = io_line[1]
        table    = handle_output("row","Speed",io_speed,table)
        io_type  = io_line[0]
        io_slot = io_line[2]
      end
      table   = handle_output("row","Type",io_type,table)
      table   = handle_output("row","Name",io_name,table)
      if model_name.match(/T2/)
        io_path = io_line[3]
      else
        if !model_name.match(/V1/)
          io_path = io_info[counter]
        end
      end
      if !model_name.match(/V1/)
        io_path = io_path.to_s
        io_path = io_path.gsub(/\s+/,'')
        io_path = io_path.gsub(/okay/,'')
      end
      table   = handle_output("row","Path",io_path,table)
      table   = handle_output("row","Slot",io_slot,table)
      ctlr_no = get_ctlr_no(io_path)
      if ctlr_no.match(/[0-9]/)
        table = handle_output("row","Controller",ctlr_no,table)
      end
      if io_path
        if model_name.match(/V1/)
          if io_path.match(/\//)
            (dev_name,drv_name,inst_no) = process_drv_info(io_path)
          end
        else
          (dev_name,drv_name,inst_no) = process_drv_info(io_path)
        end
      end
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
    if counter < length-3
      table = handle_output("line","","",table)
    end
    end
  end
  table = handle_output("end","","",table)
  return
end
