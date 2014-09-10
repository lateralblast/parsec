# Common code

# Get the System model

def get_sys_model()
  if !$sys_config["full_model_name"]
    file_name  = "/sysconfig/prtdiag-v.out"
    file_array = exp_file_to_array(file_name)
    sys_model  = file_array.grep(/^System Configuration:/)
    sys_model  = sys_model[0]
    sys_model  = sys_model.split(": ")
    sys_model  = sys_model[1]
    sys_model  = sys_model.chomp
    sys_model  = sys_model.gsub("sun4u","")
    sys_model  = sys_model.gsub("sun4v","")
    sys_model  = sys_model.gsub(/^ /,"")
    sys_model  = sys_model.gsub(/\s+/," ")
    sys_model  = sys_model.gsub(/ Server$/,"")
    $sys_config["full_model_name"] = sys_model
  else
    sys_model = $sys_config["full_model_name"]
  end
  return sys_model
end

# Get model name

def get_model_name()
  if !$sys_config["model"]
    if !$sys_config["full_model_name"]
      model_name = get_sys_model()
    else
      model_name = $sys_config["full_model_name"]
    end
    if model_name.match(/\(/)
      model_name = model_name.split(/ \(/)[0].split(/ /)[-1]
    else
      model_name = model_name.split(/ /)[-1]
    end
  else
    model_name = $sys_config["model"]
  end
  return model_name
end

# Get header for handbook file

def get_handbook_header(model)
  case model
  when /[M,T][3-9][0-9][0-9][0-9]/
    header = "Sun SPARC Enterprise "+model
  when /[X6,X8,T6][0-9][0-9][0-9]/
    header = "SunBlade"+model
  when /T[3,4][-,_]|M[10,5,6][-,_]/
    header = "SPARC "+model
  when /T[1,2][0-9][0-9][0-9]|^V|X[2,4][0-9][0-9][0-9]/
    header = "Sun SPARC Enterprise "+model
  else
    header = model
  end
  return header
end

# Get header for image file

def get_image_header(model)
  if model.match(/T[3,4]-1/)
    model = model.gsub(/-/,"_")
  end
  case model
  when /[M,T][3-9][0-9][0-9][0-9]/
    header = "SE_"+model
  when /[X,T]6[0-9][0-9][0-9]/
    header = "SunBlade"+model
  when /T[3,4][-,_]|M[10,5,6][-,_]/
    header = "SPARC_"+model
  when /T[1,2][0-9][0-9][0-9]|^V|X[2,4][0-9][0-9][0-9]/
    header = "SunFire"+model
  else
    header = model
  end
  return header
end
