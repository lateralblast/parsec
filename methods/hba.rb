# HBA related code

# Get no of ports

def get_hba_port_no(io_name)
  no_ports = "1"
  if io_name.match(/0\-S$|0$|FCX\-|10F$/)
      no_ports = "1"
  else
    if io_name.march(/1\-S$|1$|0DC\-S$|2\-S$|2$|FCX2\-|2F$/)
      no_ports = "2"
    end
  end
  return no_ports
end

# Get HBA Boot Code

def get_hba_bcode(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info = get_ctlr_info(io_path,ctlr_no)
  case ctlr_info.to_s
  when /ISP2200/
    bcode_ver = ctlr_info.grep(/BIOS/)[0].split(/Driver: /)[1].split(/ /)[0]
  when /BIOS:/
    bcode_ver = ctlr_info.grep(/BIOS/)[0].split(/BIOS: /)[1].split(/;/)[0].gsub(/ /,"")
  when /fcode:/
    bcode_ver = ctlr_info.grep(/BIOS/)[0].split(/fcode: /)[1].split(/;/)[0].gsub(/ /,"")
  else
    bcode_ver = ctlr_info.grep(/Boot/)[0]
    if bcode_ver
      bcode_ver = bcode_ver.split(/Boot:/)[1].split(/ /)[0].gsub(/ /,"")
    end
  end
  return bcode_ver
end

# Get HBA Current Speed

def get_hba_current(io_path,ctlr_no)
  hw_cfg_file = get_hw_cfg_file()
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info   = get_ctlr_info(io_path,ctlr_no)
  if hw_cfg_file.match(/prtpicl/)
    hba_current = ctlr_info.grep(/link-speed/)[0].split(/:link-speed/)[1].gsub(/\s+/,"")
  else
    hba_current = ctlr_info.grep(/Current Speed/)[0]
    if hba_current
      hba_current = hba_current.split(/: /)[1]
    end
  end
  return hba_current
end

# Get HBA Supported Speeds

def get_hba_supported(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info     = get_ctlr_info(io_path,ctlr_no)
  hba_supported = ctlr_info.grep(/Supported Speeds/)[0]
  if hba_supported
    hba_supported = hba_supported.split(/: /)[1]
  end
  return hba_supported
end

# Get HBA Firmware version

def get_hba_fw_ver(io_path,ctlr_no)
  hw_cfg_file = get_hw_cfg_file()
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info  = get_ctlr_info(io_path,ctlr_no)
  if hw_cfg_file.match(/prtpicl/)
    hba_fw_ver = ctlr_info.grep(/fcode-version/)[0].split(/:fcode-version/)[1].gsub(/\s+/,"")
    if hba_fw_ver.match(/^710/)
      hba_fw_ver = hba_fw_ver.split(/\s+/)[1]
    end
  else
    hba_fw_ver = ctlr_info.grep(/Firmware Version/)[0]
    if hba_fw_ver
      hba_fw_ver = hba_fw_ver.split(/: /)[1]
      if hba_fw_ver.match(/^710/)
        hba_fw_ver = hba_fw_ver.split(/\s+/)[1]
      end
    end
  end
  return hba_fw_ver
end

# Get HBA Driver version

def get_hba_drv_ver(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info   = get_ctlr_info(io_path,ctlr_no)
  hba_drv_ver = ctlr_info.grep(/Driver Version/)[0]
  if hba_drv_ver
    hba_drv_ver = hba_drv_ver.split(/: /)[1]
  end
  return hba_drv_ver
end

# Get HBA Driver name

def get_hba_drv_name(io_path,ctlr_no)
  hw_cfg_file = get_hw_cfg_file()
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info    = get_ctlr_info(io_path,ctlr_no)
  if hw_cfg_file.match(/prtpicl/)
    hba_drv_name = ctlr_info.grep(/driver-name/)[0].split(/:driver-name/)[1].gsub(/\s+/,"")
  else
    hba_drv_name = ctlr_info.grep(/Driver Name/)[0]
    if hba_drv_name
      hba_drv_name = hba_drv_name.split(/: /)[1]
    end
  end
  return hba_drv_name
end

# Get HBA State

def get_hba_state(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info = get_ctlr_info(io_path,ctlr_no)
  hba_state = ctlr_info.grep(/State/)[0]
  if hba_state
    hba_state = hba_state.split(/: /)[1]
  end
  return hba_state
end

# Get HBA Type

def get_hba_type(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info = get_ctlr_info(io_path,ctlr_no)
  hba_type  = ctlr_info.grep(/Type/)[0]
  if hba_type
    hba_type = hba_type.split(/: /)[1]
  end
  return hba_type
end

# Get HBA Type

def get_hba_wwn(io_path,ctlr_no)
  hw_cfg_file = get_hw_cfg_file()
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info = get_ctlr_info(io_path,ctlr_no)
  if hw_cfg_file.match(/prtpicl/)
    hba_wwn = ctlr_info.grep(/node_wwn/)[0].split(/:node_wwn/)[1].gsub(/\s+/,"")
  else
    hba_wwn = ctlr_info.grep(/Node WWN/)[0]
    if hba_wwn
      hba_wwn = hba_wwn.split(/: /)[1]
    end
  end
  return hba_wwn
end

# Get HBA Serial

def get_hba_serial(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info  = get_ctlr_info(io_path,ctlr_no)
  hba_serial = ctlr_info.grep(/Serial Number/)[0]
  if hba_serial
    hba_serial = hba_serial.split(/: /)[1]
  end
  return hba_serial
end

# Get HBA Link Failures

def get_hba_link_fail(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info     = get_ctlr_info(io_path,ctlr_no)
  hba_link_fail = ctlr_info.grep(/Link Failure Count/)[0]
  if hba_link_fail
    hba_link_fail = hba_link_fail.split(/: /)[1]
  end
  return hba_link_fail
end

# Get HBA Sync Losses

def get_hba_sync_loss(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info     = get_ctlr_info(io_path,ctlr_no)
  hba_sync_loss = ctlr_info.grep(/Loss of Sync Count/)[0]
  if hba_sync_loss
    hba_sync_loss = hba_sync_loss.split(/: /)[1]
  end
  return hba_sync_loss
end

# Get HBA Signal Loss

def get_hba_sig_loss(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info    = get_ctlr_info(io_path,ctlr_no)
  hba_sig_loss = ctlr_info.grep(/Loss of Signal Count/)[0]
  if hba_sig_loss
    hba_sig_loss = hba_sig_loss.split(/: /)[1]
  end
  return hba_sig_loss
end

# Get HBA Protocol Errors

def get_hba_proto_err(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info     = get_ctlr_info(io_path,ctlr_no)
  hba_proto_err = ctlr_info.grep(/Primitive Seq Protocol Error Count/)[0]
  if hba_proto_err
    hba_proto_err = hba_proto_err.split(/: /)[1]
  end
  return hba_proto_err
end

# Get HBA Invalid Tx Words

def get_hba_inv_tx(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info  = get_ctlr_info(io_path,ctlr_no)
  hba_inv_tx = ctlr_info.grep(/Invalid Tx Word Count/)[0]
  if hba_inv_tx
    hba_inv_tx = hba_inv_tx.split(/: /)[1]
  end
  return hba_inv_tx
end

# Get HBA Invalid CRC

def get_hba_inv_crc(io_path,ctlr_no)
  if !ctlr_no.match(/^c/)
    ctlr_no = get_ctlr_no(io_path)
  end
  ctlr_info   = get_ctlr_info(io_path,ctlr_no)
  hba_inv_crc = ctlr_info.grep(/Invalid CRC Count/)[0]
  if hba_inv_crc
    hba_inv_crc = hba_inv_crc.split(/: /)[1]
  end
  return hba_inv_crc
end

# Get HBA fcode version

def get_hba_fcode(io_path)
  file_name  = "/disks/luxadm_fcode_download_-p.out"
  file_array = exp_file_to_array(file_name)
  fc_info    = file_array.join.split("Opening Device: ")
  if io_path.match(/fibre-channel/)
    fc_info    = fc_info.grep(/FC-AL/)
  else
    fc_info    = fc_info.grep(/#{io_path}\/fp/)
  end
  fc_info    = fc_info.join.split(/\n/)[1]
  if fc_info
    fc_ver     = fc_info.split(/:/)[1]
    if fc_ver
      if fc_ver.match(/Host/)
        fc_ver = fc_info.split(/:/)[2].gsub(/^\s+/,'').split(/ /)[0]
      else
        if fc_ver.match(/SPARC/)
          fc_ver = fc_info.split(/:/)[2].split(/ \s+/)[0].gsub(/\s+/,'')
        else
          fc_ver     = fc_info.split(/:/)[1].gsub(/\s+/,'')
        end
      end
    end
  else
    fc_ver = "Unknown"
  end
  return fc_ver
end
