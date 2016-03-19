# IO related code

$io_fw_urls = []

# Get the IO slot number.
# http://docs.oracle.com/cd/E19415-01/E21618-01/App_devPaths.html

def get_io_slot(io_path,io_type,sys_model)
  io_unit = io_path.split("/")
  io_unit = io_unit[1].to_s
  if io_unit.match(/0\,6/)
    if io_type.match(/PCIx/)
      io_slot = 0
    else
      io_slot = 1
    end
  end
  if io_unit.match(/1\,7/)
    io_slot = 2
  end
  if io_unit.match(/2\,6/)
    io_slot = 3
  end
  if io_unit.match(/3\,7/)
    io_slot = 4
  end
  return io_slot.to_s
end

# Get IO path

def get_io_path(io_device,counter)
  file_name  = "/etc/path_to_inst"
  file_array = exp_file_to_array(file_name)
  if io_device.match(/,/)
    io_device = io_device.split(/,/)
    io_search = io_device[0]
    io_device = io_device[1]
    io_path   = file_array.grep(/#{io_search}/).grep(/"#{io_device}"/)[counter].split(/ /)[0].gsub(/"/,"")
  else
    io_path = file_array.grep(/"#{io_device}"/)[counter].split(/ /)[0].gsub(/"/,"")
  end
  return io_path
end

# Get IO information

def get_io_info()
  model_name = get_model_name()
  case model_name
  when /T2|T63[0,2]/
    io_info = search_prtdiag_info("IO Configuration")
  when /V1|480R|V490|280R/
    io_info = search_prtdiag_info("IO Cards")
  when /O\.E\.M\./
    io_info = search_prtdiag_info("On-Board Devices")
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

def process_io()
  model_name = get_model_name()
  io_info    = get_io_info()
  if io_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    table      = handle_table("title","IO Information","","")
    counter    = 0
    io_count   = 0
    sys_model  = get_sys_model()
    length     = io_info.grep(/[0-9]/).length
    if !model_name.match(/480R|T2|V1|V490|T63[0,2]/)
      length = length/2
    end
    dev_count  = {}
    if sys_model.match(/480|880|890|280/)
      io_type  = "PCI"
      table    = handle_table("row","Type",io_type,table)
      io_speed = "33"
      table    = handle_table("row","Speed",io_speed,table)
      io_name  = "2200"
      device   = "qlc"
      count    = 0
      io_path  = get_io_path(device,count)
      ctlr_no  = "c1"
      io_desc  = "PCI Dual FC Network Adapter+"
      table    = process_ctlr_info(table,io_name,io_path,ctlr_no)
      table    = handle_table("line","","",table)
    end
    line_count = 0
    io_info.each_with_index do |line,index|
      io_desc    = ""
      io_vendor  = ""
      io_vendid  = ""
      io_devid   = ""
      if_name    = ""
      counter = counter+1
      if line.match(/^[0-9]|^pci|^MB|^\/SYS|^IOBD|PCI|Onboard/) and !line.match(/Status/)
        io_desc     = ""
        io_name     = ""
        line_count  = line_count+1
        # Fixed squashed output
        line         = line.gsub(/PCIE3PCIE/,"PCIE3 PCI3")
        line         = line.gsub(/USBPCIX/,"USB PCIX")
        io_count     = io_count+1
        io_line      = line.chomp
        io_line      = line.split(/\s+/)
        sys_board_no = io_line[0]
        case sys_model
        when /T63[0,2]/
          io_bus  = io_line[0]
          io_type = io_line[1]
          io_slot = io_line[2]
          io_path = io_line[3]
          io_name = io_line[4]
          if io_name.match(/\,/)
            if io_name.match(/SUNW/)
              (header,io_vendid,io_devid) = io_name.split(/\,/)
            else
              (io_vendid,io_devid) = io_name.split(/\,/)
            end
            if io_devid.match(/\./)
              io_devid = io_devid.split(/\./)[0]
            end
            io_vendid = io_vendid.split(/-/)[1].gsub(/[a-z]/,"")
          end
        when /O\.E\.M\./
          io_type = io_line[1]
          io_name = io_line[2]
        when /V440/
          io_type   = io_line[0]
          io_speed  = io_line[1]
          io_slot   = io_line[2]
          io_name   = io_line[-1]
          io_name   = io_name.gsub(/\)|\(/,"")
          if io_name.match(/seria/)
            io_name = "serial"
          end
          next_line = io_info[index+1]
          next_line = next_line.split(/\s+/)
          io_status = next_line[1]
          io_path   = next_line[2]
        when /280R/
          io_board  = io_line[0]
          io_type   = io_line[1]
          io_slot   = io_line[4]
          io_speed  = io_line[5]
          io_status = io_line[-3]
          io_path   = io_line[-2]
          io_name   = io_line[-1]
          io_inst   = io_line[7]
          if io_name.match(/SUNW/)
            if io_name.match(/pci|-/)
              drv_name = io_name.split(/-/)[-1]
            end
          end
          if io_inst.match(/,/)
            io_inst1 = io_inst.split(/,/)[0]
            io_inst2 = io_inst.split(/,/)[1]
            if io_path.match(/-/)
              temp_path = io_path.split(/-/)[0]
            else
              temp_path = io_path
            end
          end
        when /480R|880R|V490/
          io_type   = io_line[0]
          io_port   = io_line[1]
          io_bus    = io_line[2]
          io_slot   = io_line[3]
          io_speed  = io_line[4]
          if sys_model.match(/V490/)
            inst_no   = io_line[6].split(/,/)[0]
            inst_no   = inst_no.to_i-1
            inst_no   = inst_no.to_s
            io_status = io_line[7]
          else
            inst_no   = io_line[5].split(/,/)[0]
            io_status = io_line[6]
          end
          io_path   = io_line[-1]
          if !io_path.match(/-/)
            io_path = io_line[-2]
            io_name = io_line[-1]
          end
          if io_path.match(/qlc/)
            if io_path.match(/[0-9]/)
              if io_path.match(/SUNW/)
                (header,io_vendid,io_devid) = io_path.split(/\,/)
              else
                (io_vendid,io_devid) = io_path.split(/\,/)
              end
              if io_devid.match(/\./)
                io_devid = io_devid.split(/\./)[0]
              end
              io_vendid = io_vendid.split(/-/)[1].gsub(/[a-z]/,"")
            end
            io_name = io_path.split(/,/)[2].split(/\./)[0]
            io_name = "ISP"+io_name.to_s
            device  = io_path.split(/\-/)[0]
            if !dev_count[device]
              temp_count = 0
              dev_count[device] = temp_count+1
            else
              temp_count = dev_count[device]
              dev_count[device] = temp_count+1
            end
            io_path = get_io_path(device,temp_count)
          else
            if io_path.match(/[0-9]/)
              (io_vendid,io_devid) = io_path.split(/\,/)
              if io_devid.match(/\./)
                io_devid = io_devid.split(/\./)[0]
              end
              io_vendid = io_vendid.split(/-/)[1].gsub(/[a-z]/,"")
              if io_path.match(/channel/)
                io_path  = "fibre-channel"
                drv_name = "qlc"
              end
              (io_path,inst_no,drv_name) = search_path_to_inst(io_path,inst_no,drv_name)
            end
          end
        when /T[5,7]-/
          io_slot = io_line[0]
          io_type = io_line[1]
          io_name = io_line[3]
          if io_name.match(/GT/)
            io_name = "N/A"
          end
          io_max  = io_line[-2]
          io_now  = io_line[-1]
        when /V1/
          sys_board_no = io_line[1]
          io_type      = io_line[2]
          io_speed     = io_line[3]+" MHz"
          io_slot      = io_line[4]
          io_path      = io_line[5]
          if io_line[6]
            io_path = io_line[5]
            io_name = io_line[6]
          else
            io_name = io_path
          end
          if io_path.match(/[0-9]/)
            (io_vendid,io_devid) = io_path.split(/\,/)
            if io_devid.match(/\./)
              io_devid = io_devid.split(/\./)[0]
            end
            io_vendid = io_vendid.split(/-/)[1].gsub(/[a-z]/,"")
          end
          if io_path.match(/glm|fc/)
            device = io_path.split(/\-/)[1]
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
            device = io_name.split(/\-/)[1]
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
          if sys_board_no
            table   = handle_table("row","IOU",sys_board_no,table)
          end
          io_type   = io_line[1]
          io_devid  = io_line[4].gsub(/\,/,"")
          io_vendid = io_line[5]
          io_path   = io_info[counter].gsub(/\s+/,"")
          io_slot   = get_io_slot(io_path,io_type,sys_model)
        when /M10-/
          io_slot  = io_line[0]
          io_type  = io_line[1]
          io_name  = io_line[-2]
          io_speed = io_line[-1]
          io_path  = io_info[index+1].gsub(/^\s+|\s+$/,"")
        when /M[5,6,7]-/
          io_path  = io_info[index+1]
          if io_path
            io_path  = io_path.gsub(/^\s+|\s+$/,"")
          end
          io_slot  = io_line[0]
          io_type  = io_line[1]
          if sys_model.match(/M7-8/)
            io_name  = io_line[3]
            io_max   = io_line[4]
            io_speed = io_line[5]
            io_class = io_line[2]
            if io_class.match(/[0-9]/)
              if io_class.match(/SUNW/)
                (header,io_vendid,io_devid) = io_class.split(/\,/)
              else
                (io_vendid,io_devid) = io_class.split(/\,/)
              end
              if io_devid
                if io_devid.match(/\./)
                  io_devid = io_devid.split(/\./)[0]
                end
              end
              if io_vendid
                if io_vendid.match(/-/)
                  io_vendid = io_vendid.split(/-/)[1].gsub(/[a-z]/,"")
                end
              end
            end
          else
            io_name  = io_line[2]
            io_speed = io_line[-1]
          end
        when /T[3,4,6,7]-/
          io_slot  = io_line[0]
          io_type  = io_line[1].gsub(/PCI3/,"PCIE")
          io_speed = io_line[-1]
          sys_board_no = io_line[0].split(/\//)[2]
          if line.match(/LSI|qlc|emlx/)
            io_name = io_line[-2]
          else
            io_name = "N/A"
          end
        when /T5[0-9][0-9]|T6340/
          if sys_model.match(/T5440|T6340/)
            io_slot = io_line[0]
            io_type = io_line[1]
            io_name = io_line[-1]
            if io_name.match(/\,[0-9][0-9][0-9][0-9]$/)
              io_temp = io_line[-1]
            else
              io_temp = io_line[-2]
            end
            if io_temp.match(/\,/) and !io_temp.match(/^[A-R,T-Z]/)
              if io_temp.match(/SUNW/)
                (header,io_vendid,io_devid) = io_temp.split(/\,/)
              else
                (io_vendid,io_devid) = io_temp.split(/\,/)
              end
              if io_devid
                if io_devid.match(/\./)
                  io_devid = io_devid.split(/\./)[0]
                end
              else
                io_devid = ""
              end
              io_vendid = io_vendid.split(/-/)[1].gsub(/[a-z]/,"")
            end
          else
            io_type = io_line[1].gsub(/PCI3/,"PCIE")
            io_slot = io_line[0]
            if line.match(/LSI|qlc|emlx/)
              io_name = io_line[-1]
              if io_name.match(/Tx/)
                io_name  = io_line[-2]
                io_speed = io_line[-1]
              end
            else
              io_speed = io_line[-1]
              io_name  = "N/A"
            end
            sys_board_no = io_line[0].split(/\//)[0]
          end
        when /T2/
          io_type = io_line[1]
          io_slot = io_line[0]
          io_path = io_line[3]
          if line.match(/LSI|qlc|emlx/)
            io_name = io_line[-1]
            if io_name.match(/[0-9]LP/)
              io_name = io_name.split(/LP/)[1]
              io_name = "LP"+io_name
            end
          else
            io_name = io_line[-1]
            if io_name.match(/\,/)
              (io_vendid,io_devid) = io_name.split(/\,/)
              if io_devid.match(/\./)
                io_devid = io_devid.split(/\./)[0]
              end
              io_vendid = io_vendid.split(/-/)[1].gsub(/[a-z]/,"")
            end
          end
        else
          io_type  = io_line[0]
          io_speed = io_line[1]
          table    = handle_table("row","Speed",io_speed,table)
          io_type  = io_line[0]
          io_slot = io_line[2]
        end
        if io_type
          table = handle_table("row","Type",io_type,table)
        end
        if io_port
          table = handle_table("row","Port",io_port,table)
        end
        if io_bus
          table = handle_table("row","Bus",io_bus,table)
        end
        if io_status
          table = handle_table("row","Bus",io_status,table)
        end
        if io_name
          table = handle_table("row","Name",io_name,table)
          if io_name.match(/^7/)
            if io_path.match(/qlc|emlx|oce/)
              $hba_part_list.each do |hba_name, hba_info|
                if hba_info.match(/#{io_name}/)
                  table = handle_table("row","Model",hba_name,table)
                end
              end
            end
          end
        end
        if io_speed
          table = handle_table("row","Speed",io_speed,table)
        end
        if io_max
          table = handle_table("row","Max Speed",io_max,table)
        end
        if io_now
          table = handle_table("row","Max Speed",io_now,table)
        end
        if !model_name.match(/480R|V490|280R/)
          if model_name.match(/T2/)
            io_path = io_line[3]
          else
            if !model_name.match(/V1/)
              io_path = io_info[counter]
            end
          end
        end
        if !model_name.match(/V1|480R|V490|280R/)
          io_path = io_path.to_s
          io_path = io_path.gsub(/\s+/,'')
          io_path = io_path.gsub(/okay/,'')
        end
        if io_path
          case io_path
          when /^ebus$/
            io_desc = "PCI/ISA Bridge"
          when /^isa$/
            io_desc = "ISA Bridge"
          when /^lomp$/
            io_desc = "Lights Out Management Device"
          when /^pmu/
            io_desc = "Power Management Unit"
          when /usb\@/
            io_desc = "USB Controller"
          end
          table = handle_table("row","Path",io_path,table)
        end
        if io_slot
          table = handle_table("row","Slot",io_slot,table)
        end
        ctlr_no = get_ctlr_no(io_path)
        if ctlr_no.match(/[0-9]/)
          table = handle_table("row","Controller",ctlr_no,table)
        end
        if io_path
          if model_name.match(/V1/)
            if io_path.match(/\//)
              (dev_name,drv_name,inst_no) = process_drv_info(io_path)
            end
          else
            if dev_name
              (dev_name,drv_name,inst_no) = process_drv_info(io_path)
            end
          end
        end
        if !drv_name
          if io_path or inst_no or drv_name
            (io_path,inst_no,drv_name) = search_path_to_inst(io_path,inst_no,drv_name)
          end
        end
        if drv_name
          table = handle_table("row","Driver",drv_name,table)
        end
        if inst_no
          if io_inst1 or io_inst2
            if io_inst1
              (io_path,inst_no,drv_name) = search_path_to_inst(io_path,io_inst1,drv_name)
              table = handle_table("row","Instance 1",inst_no,table)
            end
            if io_inst2
              (io_path,inst_no,drv_name) = search_path_to_inst(io_path,io_inst2,drv_name)
              table = handle_table("row","Instance 2",inst_no,table)
            end
          else
            table = handle_table("row","Instance",inst_no,table)
          end
        end
        if io_path.match(/network|oce/)
          port_no = io_path[-1]
          table   = handle_table("row","Port",port_no,table)
          os_ver  = get_os_version()
          if os_ver.match(/11/)
            link_name = get_link_name(dev_name)
            if link_name
              table = handle_table("row","Link",link_name,table)
            end
            aggr_name = process_aggr_info(link_name)
          else
            aggr_name = process_aggr_info(dev_name)
          end
          if os_ver.match(/11/)
            (link_state,link_auto,link_speed) = get_link_details(link_name)
            if link_state
              table = handle_table("row","State",link_state,table)
            end
            if link_auto
              table = handle_table("row","Auto",link_auto,table)
            end
            if link_speed
              table = handle_table("row","Speed",link_speed,table)
            end
          end
          if aggr_name.match(/[a-z,A-Z,0-9]/)
            table = handle_table("row","Aggregate",aggr_name,table)
            if_hostname = get_if_hostname(aggr_name)
          else
            io_insts = []
            if io_inst1 or io_inst2
              if io_inst1
                io_insts.push(io_inst1)
              end
              if io_inst2
                io_insts.push(io_inst2)
              end
            else
              if io_inst
                io_insts.push(io_inst)
              end
            end
            io_insts.each do |inst_no|
              if_name = drv_name+inst_no
              if $masked == 0
                table = handle_table("row","Interface #{inst_no}",if_name,table)
              else
                table = handle_table("row","Interface #{inst_no}","MASKED",table)
              end
              if_hostname = get_if_hostname(if_name)
            end
          end
          if if_hostname
            if $masked == 0
              table = handle_table("row","Hostname",if_hostname,table)
            else
              table = handle_table("row","Hostname","MASKED",table)
            end
            if_ip = get_hostname_ip(if_hostname)
            if if_ip
              if if_name
                ip_string = "IP ("+if_name+")"
              else
                ip_string = "IP"
              end
              if $masked == 0
                table = handle_table("row",ip_string,if_ip,table)
              else
                table = handle_table("row",ip_string,"MASKED",table)
              end
            end
          end
        end
        if io_slot
          if io_slot.match(/USB/)
            io_desc = "USB Controller"
          end
          if io_slot.match(/VIDEO/)
            io_desc = "Video Controller"
          end
        end
        if io_path.match(/^usb/)
          io_desc = "USB Controller"
        end
        if io_path.match(/^ide/)
          io_desc = "IDE Controller"
        end
        if io_path.match(/network/)
          if !io_name.match(/N\/A/)
            nic_part_info = $nic_part_list[io_name]
          else
            nic_part_info = $nic_part_list[drv_name]
          end
          if nic_part_info
            nic_part_info = nic_part_info.split(/,/)
            nic_part_no   = nic_part_info[0]
            nic_part_desc = nic_part_info[1]
            if nic_part_no
              if nic_part_no.match(/[A-Z]|[0-9]/)
                io_desc = nic_part_no
              end
            end
            if nic_part_desc
              io_desc = nic_part_desc
            end
          end
        end
        if !io_desc
          io_desc = ""
        end
        if !io_desc.match(/[A-Z]|[a-z]/)
          io_desc = get_io_desc_from_driver(drv_name)
        end
        if io_vendid.match(/[0-9]/)
          table     = handle_table("row","Vendor ID",io_vendid,table)
          io_vendor = get_io_vendor_from_vendor_id(io_vendid)
          table     = handle_table("row","Vendor Name",io_vendor,table)
        end
        if io_devid.match(/[0-9]/)
          table    = handle_table("row","Device ID",io_devid,table)
          io_devid = get_io_device_from_vendor_id(io_vendid,io_devid)
          table    = handle_table("row","Device Name",io_devid,table)
        end
        if io_desc.match(/[a-z]|[A-Z]|[0-9]/)
          table = handle_table("row","Part Description",io_desc,table)
        end
        table = process_ctlr_info(table,io_name,io_path,ctlr_no)
        if line_count < length
          table = handle_table("line","","",table)
        end
      end
    end
    table = handle_table("end","","",table)
  else
    puts
    puts "No IO information available"
  end
  if $io_fw_urls[0]
    handle_output("\n")
    $io_fw_urls.each_with_index do |url, index|
      ref    = index+1
      output = "["+ref.to_s+"] "+url+"\n"
      handle_output(output)
    end
    handle_output("\n")
  end
  return
end
