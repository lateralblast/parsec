# Controller related code

# Get the IO slot number.
# http://docs.oracle.com/cd/E19415-01/E21618-01/App_devPaths.html

def get_io_slot(io_path,io_type,sys_model)
  ctlr_no = get_ctlr_no(io_path)
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

# Get the controller number.
# Use information in the IO path name to get information.

def get_ctlr_no(io_path)
  ctlr_no = ""
  # Handle FC devices
  if io_path.match(/emlxs|scsi|qlc/)
    # Get controller name by searching dev list for IO path
    # We do this as the kernel driver in path_to_inst is fp
    # whereas the controller is cX in everything else
    file_name  = "/disks/ls-l_dev_cfg.out"
    file_array = exp_file_to_array(file_name)
    ctlr_no    = file_array.grep(/#{io_path}/)
    ctlr_no    = ctlr_no.to_s.split(" ")
    ctlr_no    = ctlr_no[8].to_s
  end
  return ctlr_no
end

# Process controller number

def process_ctlr_no(table,io_path)
  ctlr_no = get_ctlr_no(io_path)
  table   = handle_output("row","Controller",ctlr_no,table)
  return table
end

# Get controller information

def get_ctlr_info(io_path,ctlr_no)
  # Handle FC devices
  os_ver = get_os_ver()
  if io_path.match(/emlxs|qlc/)
    fc_info = get_fc_info()
    if os_ver.match(/10|11/)
      ctlr_path = "/dev/cfg/"+ctlr_no
      fc_info   = fc_info.grep(/#{ctlr_path}/)
    else
      fc_info = fc_info.grep(/#{io_path}\/fp/)
    end
    fc_info = fc_info.join.split(/\n/)
    return fc_info
  end
end

# Processes fcinfo into an array

def process_ctlr_info(table,io_name,io_path,ctlr_no)
  ctlr_info  = get_ctlr_info(io_path,ctlr_no)
  os_ver     = get_os_ver()
  # Handle FC devices
  no_ports = ""
  fc_speed = ""
  pci_str  = ""
  if io_path.match(/emlxs|qlc/)
    if os_ver.match(/10|11/)
      hba_serial = get_hba_serial(io_path,ctlr_no)
      if $masked == 0
        table = handle_output("row","Serial",hba_serial,table)
      else
        table = handle_output("row","Serial","XXXXXXXX",table)
      end
      hba_wwn = get_hba_wwn(io_path,ctlr_no)
      if $masked == 0
        table = handle_output("row","Node WWN",hba_wwn,table)
      else
        table = handle_output("row","Node WWN","XXXXXXXX",table)
      end
      hba_state     = get_hba_state(io_path,ctlr_no)
      table         = handle_output("row","State",hba_state,table)
      hba_type      = get_hba_type(io_path,ctlr_no)
      table         = handle_output("row","Type",hba_type,table)
      bcode_ver     = get_hba_bcode(io_path,ctlr_no)
      table         = handle_output("row","BCode",bcode_ver,table)
      hba_current   = get_hba_current(io_path,ctlr_no)
      table         = handle_output("row","Current Speed",hba_current,table)
      hba_supported = get_hba_supported(io_path,ctlr_no)
      table         = handle_output("row","Supported Speeds",hba_supported,table)
      hba_fw_ver    = get_hba_fw_ver(io_path,ctlr_no)
      table         = handle_output("row","Firmware Version",hba_fw_ver,table)
      hba_drv_name  = get_hba_drv_name(io_path,ctlr_no)
      table         = handle_output("row","Driver Name",hba_drv_name,table)
      hba_drv_ver   = get_hba_drv_ver(io_path,ctlr_no)
      table         = handle_output("row","Driver Version",hba_drv_ver,table)
      hba_link_fail = get_hba_link_fail(io_path,ctlr_no)
      table         = handle_output("row","Link Failures",hba_link_fail,table)
      hba_sync_loss = get_hba_sync_loss(io_path,ctlr_no)
      table         = handle_output("row","Sync Losses",hba_sync_loss,table)
      hba_sig_loss  = get_hba_sig_loss(io_path,ctlr_no)
      table         = handle_output("row","Signal Losses",hba_sig_loss,table)
      hba_proto_err = get_hba_proto_err(io_path,ctlr_no)
      table         = handle_output("row","Protocol Errors",hba_proto_err,table)
      hba_inv_tx    = get_hba_inv_tx(io_path,ctlr_no)
      table         = handle_output("row","Invalid Tx Words",hba_inv_tx,table)
      hba_inv_crc   = get_hba_inv_crc(io_path,ctlr_no)
      table         = handle_output("row","Invalid CRC",hba_inv_crc,table)
    end
    fcode_ver     = get_hba_fcode(io_path)
    table         = handle_output("row","FCode",fcode_ver,table)
    hba_part_info = $hba_part_list[io_name]
    if hba_part_info
      hba_part_info = hba_part_info.split(/,/)
      hba_part_no   = hba_part_info[0]
      hba_part_desc = hba_part_info[1]
      table         = handle_output("row","Part Number",hba_part_no,table)
    else
      table         = handle_output("row","Part Number",io_name,table)
    end
    if io_path.match(/emlxs/)
      table = process_avail_em_fw(table,io_name,hba_fw_ver)
    end
    if io_path.match(/qlc/)
      table = process_avail_ql_fw(table,hba_part_no,hba_fw_ver)
    end
    table = handle_output("row","Part Description",hba_part_desc,table)
  end
  if io_path.match(/emlxs|qlc|scsi/)
    if $do_disks == 1
      process_disk_info(table,ctlr_no)
    end
  end
  return table
end
