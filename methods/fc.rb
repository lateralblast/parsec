# FC related code

# Get FC device information and put it in an array
# Information is in a multi line form so split it
# on the HBA Port WWN string so all the information
# about a controller is in an array element

def get_fc_info()
  os_ver     = get_os_ver()
  model_name = get_model_name()
  if model_name.match(/T[1,2]/)
    file_name  = "/sysconfig/prtpicl-v.out"
    file_array = exp_file_to_array(file_name)
    fc_info    = file_array.join.split(/\(scsi-fcp/)[1..-1].join.split(/is-io\(/)[0].split(/\(scsi-fcp/)
  else
    if os_ver.match(/10|11/)
      file_name  = "/sysconfig/fcinfo.out"
      file_array = exp_file_to_array(file_name)
      fc_info    = file_array.join.split("HBA Port WWN: ")
    else
      file_name  = "/disks/luxadm_fcode_download_-p.out"
      file_array = exp_file_to_array(file_name)
      fc_info    = file_array.join.split("Opening Device: ")
    end
  end
  return fc_info
end
