# Controller related code

# Get the controller number.
# Use information in the IO path name to get information.

def get_ctlr_no(io_path)
  # Get controller name by searching dev list for IO path
  # We do this as the kernel driver in path_to_inst is fp
  # whereas the controller is cX in everything else
  # except for oce on M[5,6]-32s
  if io_path.match(/oce@/)
    file_name = "/disks/ls_-lAR_@dev_@devices.out"
  else
    file_name = "/disks/ls-l_dev_cfg.out"
  end
  file_array = exp_file_to_array(file_name)
  ctlr_no    = file_array.grep(/#{io_path}/)
  ctlr_no    = ctlr_no.to_s.split(" ")
  ctlr_no    = ctlr_no[8].to_s
  return ctlr_no
end

# Process controller number

def process_ctlr_no(table,io_path)
  ctlr_no = get_ctlr_no(io_path)
  table   = handle_table("row","Controller",ctlr_no,table)
  return table
end

# Get controller information

def get_ctlr_info(io_path,ctlr_no)
  # Handle FC devices
  os_ver      = get_os_ver()
  hw_cfg_file = get_hw_cfg_file()
  if io_path.match(/emlxs|qlc|fibre-channel/)
    fc_info = get_fc_info()
    if os_ver.match(/10|11/) and hw_cfg_file.match(/prtdiag/)
      ctlr_path = "/dev/cfg/"+ctlr_no
      fc_info   = fc_info.grep(/#{ctlr_path}\n/)
    else
      fc_info = fc_info.grep(/#{io_path}\/fp/)
    end
    fc_info = fc_info.join.split(/\n/)
    return fc_info
  end
end

# Processes fcinfo into an array

def process_ctlr_info(table,io_name,io_path,ctlr_no)
  os_ver      = get_os_ver()
  hw_cfg_file = get_hw_cfg_file()
  # Handle SCSI devices
  if io_path.match(/scsi/)
    scsi_part_info = $scsi_part_list[io_name]
    if scsi_part_info
      scsi_part_info = scsi_part_info.split(/,/)
      scsi_part_no   = scsi_part_info[0]
      scsi_part_desc = scsi_part_info[1]
      if scsi_part_no
        if scsi_part_no.match(/[A-Z]|[0-9]/)
          table = handle_table("row","Part Number",scsi_part_no,table)
        end
      end
      if scsi_part_desc
        table = handle_table("row","Part Description",scsi_part_desc,table)
      end
    end
  end
  # Handle FC devices
  if io_path.match(/emlxs|qlc|fibre-channel/)
    if os_ver.match(/10|11/)
      if !hw_cfg_file.match(/prtpicl/)
        hba_serial = get_hba_serial(io_path,ctlr_no)
        table = handle_table("row","Serial",hba_serial,table)
      end
      hba_wwn = get_hba_wwn(io_path,ctlr_no)
      if hba_wwn
        table = handle_table("row","Node WWN",hba_wwn,table)
      end
      hba_state = get_hba_state(io_path,ctlr_no)
      if !hw_cfg_file.match(/prtpicl/)
        if hba_state
          table = handle_table("row","State",hba_state,table)
        end
        hba_type = get_hba_type(io_path,ctlr_no)
        if hba_type
          table = handle_table("row","Type",hba_type,table)
        end
        bcode_ver = get_hba_bcode(io_path,ctlr_no)
        if bcode_ver
          table = handle_table("row","BCode",bcode_ver,table)
        end
      else
        table = handle_table("row","Type","PCI",table)
      end
      hba_current = get_hba_current(io_path,ctlr_no)
      if hba_current
        table = handle_table("row","Current Speed",hba_current,table)
      end
      if !hw_cfg_file.match(/prtpicl/)
        hba_supported = get_hba_supported(io_path,ctlr_no)
        if hba_supported
          table = handle_table("row","Supported Speeds",hba_supported,table)
        end
      end
      hba_fw_ver = get_hba_fw_ver(io_path,ctlr_no)
      if hba_fw_ver
        table = handle_table("row","Firmware Version",hba_fw_ver,table)
      end
      hba_drv_name = get_hba_drv_name(io_path,ctlr_no)
      if hba_drv_name
        table = handle_table("row","Driver Name",hba_drv_name,table)
      end
      if !hw_cfg_file.match(/prtpicl/)
        hba_drv_ver = get_hba_drv_ver(io_path,ctlr_no)
        if hba_drv_ver
          table = handle_table("row","Driver Version",hba_drv_ver,table)
        end
        hba_link_fail = get_hba_link_fail(io_path,ctlr_no)
        if hba_link_fail
          table = handle_table("row","Link Failures",hba_link_fail,table)
        end
        hba_sync_loss = get_hba_sync_loss(io_path,ctlr_no)
        if hba_sync_loss
          table = handle_table("row","Sync Losses",hba_sync_loss,table)
        end
        hba_sig_loss  = get_hba_sig_loss(io_path,ctlr_no)
        if hba_sig_loss
          table = handle_table("row","Signal Losses",hba_sig_loss,table)
        end
        hba_proto_err = get_hba_proto_err(io_path,ctlr_no)
        if hba_proto_err
          table = handle_table("row","Protocol Errors",hba_proto_err,table)
        end
        hba_inv_tx = get_hba_inv_tx(io_path,ctlr_no)
        if hba_inv_tx
          table = handle_table("row","Invalid Tx Words",hba_inv_tx,table)
        end
        hba_inv_crc = get_hba_inv_crc(io_path,ctlr_no)
        if hba_inv_crc
          table = handle_table("row","Invalid CRC",hba_inv_crc,table)
        end
        fcode_ver = get_hba_fcode(io_path)
        if fcode_ver
          table = handle_table("row","FCode",fcode_ver,table)
        end
      end
    end
    if io_path.match(/qlc/)
      if io_name.match(/,/)
        if io_name.match(/pciex/)
          io_name = "QLE"+io_name.split(/,/)[-1]
        else
          io_name = "QLA"+io_name.split(/,/)[-1]
        end
      end
    end
    hba_part_info = $hba_part_list[io_name]
    if hba_part_info
      hba_part_info = hba_part_info.split(/,/)
      hba_part_no   = hba_part_info[0]
      hba_part_desc = hba_part_info[1]
      if hba_part_no
        table = handle_table("row","Part Number",hba_part_no,table)
      end
    else
      if io_name
        table = handle_table("row","Part Number",io_name,table)
      end
    end
    if io_path.match(/emlxs/)
      if hba_fw_ver
        table = process_avail_em_fw(table,io_name,hba_fw_ver)
      end
    end
    if io_path.match(/qlc|fibre-channel/)
      if hba_fw_ver
        table = process_avail_ql_fw(table,hba_part_no,hba_fw_ver)
      end
    end
    if hba_part_desc
      table = handle_table("row","Part Description",hba_part_desc,table)
    end
  end
  if io_path.match(/oce/)
    hba_part_info = $hba_part_list[io_name]
    if hba_part_info
      hba_part_info = hba_part_info.split(/,/)
      hba_part_no   = hba_part_info[0]
      hba_part_desc = hba_part_info[1]
      if hba_part_no
        table = handle_table("row","Part Number",hba_part_no,table)
      end
      if hba_part_desc
        table = handle_table("row","Part Description",hba_part_desc,table)
      end
    end
  end
  if io_path.match(/emlxs|qlc|scsi/)
    if $do_disks == 1
      process_iostat_info(table,ctlr_no)
    end
  end
  return table
end
