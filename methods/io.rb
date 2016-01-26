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
  when /T2/
    io_info = search_prtdiag_info("IO Configuration")
  when /V1|480R/
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

def process_io()
  model_name = get_model_name()
  io_info    = get_io_info()
  if io_info.to_s.match(/[A-Z]|[a-z]|[0-9]/)
    table      = handle_table("title","IO Information","","")
    counter    = 0
    io_count   = 0
    sys_model  = get_sys_model()
    length     = io_info.grep(/[0-9]/).length
    if !model_name.match(/480R|T2|V1/)
      length = length/2
    end
    dev_count  = {}
    if sys_model.match(/480|880|490|890|280/)
      io_name = "2200"
      device  = "qlc"
      count   = 0
      io_path = get_io_path(device,count)
      ctlr_no = "c1"
      table = process_ctlr_info(table,io_name,io_path,ctlr_no)
      table = handle_table("line","","",table)
    end
    line_count = 0
    io_info.each_with_index do |line,index|
      counter = counter+1
      if line.match(/^[0-9]|^pci|^MB|^\/SYS|^IOBD|PCI/) and !line.match(/Status/)
        line_count  = line_count+1
        # Fixed squashed output
        line         = line.gsub(/PCIE3PCIE/,"PCIE3 PCI3")
        line         = line.gsub(/USBPCIX/,"USB PCIX")
        io_count     = io_count+1
        io_line      = line.chomp
        io_line      = line.split(/\s+/)
        sys_board_no = io_line[0]
        case sys_model
        when /480R|880R/
          io_type   = io_line[0]
          io_port   = io_line[1]
          io_bus    = io_line[2]
          io_slot   = io_line[3]
          io_speed  = io_line[4]
          io_status = io_line[6]
          io_path   = io_line[-1]
          if io_path.match(/qlc/)
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
          if sys_board_no
            table   = handle_table("row","IOU",sys_board_no,table)
          end
          io_type = io_line[1]
          io_path = io_info[counter].gsub(/\s+/,"")
          io_slot = get_io_slot(io_path,io_type,sys_model)
        when /M10-/
          io_slot  = io_line[0]
          io_type  = io_line[1]
          io_name  = io_line[-2]
          io_speed = io_line[-1]
          io_path  = line[index+1].gsub(/^\s+|\s+$/,"")
        when /M[5,6,7]-/
          io_slot  = io_line[0]
          io_type  = io_line[1]
          io_name  = io_line[2]
          io_speed = io_line[-1]
          io_path  = line[index+1]
          if io_path
            io_path  = io_path.gsub(/^\s+|\s+$/,"")
          end
        when /T[3,4,6]-/
          io_slot  = io_line[0]
          io_type  = io_line[1].gsub(/PCI3/,"PCIE")
          io_speed = io_line[-1]
          sys_board_no = io_line[0].split(/\//)[2]
          if line.match(/LSI|qlc|emlx/)
            io_name = io_line[-2]
          else
            io_name = "N/A"
          end
        when /T5[0-9][0-9]/
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
        if !model_name.match(/480R/)
          if model_name.match(/T2/)
            io_path = io_line[3]
          else
            if !model_name.match(/V1/)
              io_path = io_info[counter]
            end
          end
        end
        if !model_name.match(/V1|480R/)
          io_path = io_path.to_s
          io_path = io_path.gsub(/\s+/,'')
          io_path = io_path.gsub(/okay/,'')
        end
        if io_path
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
            (dev_name,drv_name,inst_no) = process_drv_info(io_path)
          end
        end
        if drv_name
          table = handle_table("row","Driver",drv_name,table)
        end
        if inst_no
          table = handle_table("row","Instance",inst_no,table)
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
          if aggr_name
            table = handle_table("row","Aggregate",aggr_name,table)
            if_hostname = get_if_hostname(aggr_name)
          else
            if_name = drv_name+inst_no
            if $masked == 0
              table = handle_table("row","Interface",if_name,table)
            else
              table = handle_table("row","Interface","MASKED",table)
            end
            if_hostname = get_if_hostname(if_name)
          end
          if if_hostname
            if $masked == 0
              table = handle_table("row","Hostname",if_hostname,table)
            else
              table = handle_table("row","Hostname","MASKED",table)
            end
            if_ip = get_hostname_ip(if_hostname)
            if if_ip
              if $masked == 0
                table = handle_table("row","IP",if_ip,table)
              else
                table = handle_table("row","IP","MASKED",table)
              end
            end
          end
        end
        if io_slot
          if io_slot.match(/USB/)
            table = handle_table("row","Part Description","USB Controller",table)
          end
          if io_slot.match(/VIDEO/)
            table = handle_table("row","Part Description","Video Controller",table)
          end
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
                table = handle_table("row","Part Number",nic_part_no,table)
              end
            end
            if nic_part_desc
              table = handle_table("row","Part Description",nic_part_desc,table)
            end
          end
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
