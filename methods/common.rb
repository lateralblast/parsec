# Common code

# Check file type

def check_file_type(file_name)
  if File.exist?(file_name)
    file_check = %x[file #{file_name}].chomp
    if file_check.match(/empty/)
      File.delete(file_name)
    end
  end
  if File.exist?(file_name) and file_name.match(/zip$/)
    file_check = %x[file "#{file_name}"].chomp
    if file_check.match(/HTML/)
      File.delete(file_name)
    end
  end
  return
end

# Get the file type

def get_file_type(file_name)
  if File.exist?(file_name)
    file_type = %x[file --brief --mime-type #{file_name}].strip
  else
    file_type = "none"
  end
  return file_type
end

# Get OS version

def get_os_version()
  os_version = $host_info["OS Version"]
  if !os_version
    os_version = get_os_ver()
  end
  return os_version
end

# Get download

def get_download(url,output_file)
  check_file_type(output_file)
  if !File.exist?(output_file)
    if $verbose == 1
      handle_output("Downloading: #{url}\n")
      handle_output("Destination: #{output_file}\n")
    end
    output_dir = File.dirname(output_file)
    if !Dir.exist?(output_dir)
      begin
        Dir.mkdir(output_dir)
      rescue
        handle_output("Cannot creating directory #{output_dir}\n")
        exit
      end
    end
    if $test_mode == 0
      if url.match(/Orion|getupdates|handbook_private/)
        (mos_username,mos_password) = get_mos_details()
        get_mos_url(url,output_file)
      else
        agent = Mechanize.new
        agent.redirect_ok = true
        agent.pluggable_parser.default = Mechanize::Download
        begin
          agent.get(url).save(output_file)
        rescue
          if $verbose == 1
            handle_output("Error fetching: #{url}\n")
          end
        end
      end
    end
  else
    if $verbose == 1
      handle_output("File: #{output_file} already exists\n")
    end
  end
  return
end

# Get a MOS page

def get_mos_url(mos_url,local_file)
  if $verbose == 1
    handle_output("Downloading #{mos_url} to #{local_file}\n")
  end
  if mos_url.match(/patch_file|zip$/)
    mos_passwd_file = Dir.home+"/.mospasswd"
    if !File.exist?(mos_passwd_file)
      (mos_username,mos_password)=get_mos_details()
      create_mos_passwd_file(mos_username,mos_password)
    end
    if $verbose == 1
      command="export WGETRC="+mos_passwd_file+"; wget --no-check-certificate "+"\""+mos_url+"\""+" -O "+"\""+local_file+"\""
    else
      command="export WGETRC="+mos_passwd_file+"; wget --no-check-certificate "+"\""+mos_url+"\""+" -q -O "+"\""+local_file+"\""
    end
    system(command)
  else
    (mos_username,mos_password) = get_mos_details()
    cap = Selenium::WebDriver::Remote::Capabilities.phantomjs('phantomjs.page.settings.userAgent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/538.39.41 (KHTML, like Gecko) Version/8.0 Safari/538.39.41')
    doc = Selenium::WebDriver.for :phantomjs, :desired_capabilities => cap
    mos = "https://supporthtml.oracle.com"
    doc.get(mos)
    doc.manage.timeouts.implicit_wait = 20
    doc.find_element(:id => "pt1:gl3").click
    doc.find_element(:id => "Mssousername").send_keys(mos_username)
    doc.find_element(:id => "Mssopassword").send_keys(mos_password)
    doc.find_element(:link => "Sign In").click
    doc.get(mos_url)
    file = File.open(local_file,"w")
    file.write(doc.page_source)
    file.close
  end
  return
end

# If a ~/,mospasswd doesn't exist ask for details

def get_mos_details()
  mos_passwd_file = Dir.home+"/.mospasswd"
  if !File.exist?(mos_passwd_file)
    puts "Enter MOS Username:"
    STDOUT.flush
    mos_username = gets.chomp
    puts "Enter MOS Password:"
    STDOUT.flush
    mos_password = gets.chomp
    create_mos_passwd_file(mos_username,mos_password)
  else
    mos_data = File.readlines(mos_passwd_file)
    mos_data.each do |line|
      line.chomp
      if line.match(/http-user/)
        mos_username = line.split(/\=/)[1].chomp
      end
      if line.match(/http-password/)
        mos_password = line.split(/\=/)[1].chomp
      end
    end
  end
  return mos_username,mos_password
end

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
  model = model.gsub(/M2$/,"_M2")
  case model
  when /X[2,4][0-9][0-9][0-9]/
    header = "SunFire"+model
  when /^N/
    header = "Netra_"+model.gsub(/^N/,"")
  when /^V|K$/
    header = "SunFire"+model
  when /X6[0-9][0-9][0-9]|X8[0-9][0-9][0-9]|T6[0-9][0-9][0-9]/
    header = "SunBlade"+model
  when /T3-|T4-|T5-|M10-|M5-|M6-/
    header = "SPARC_"+model
  when /X[3,4][-,_]/
    header = "Sun_Server_"+model
  when /O[3,4][-,_]/
    header = "ODA_"+model.gsub(/^O/,"X")
  when /ULTRA[0-9]/
    header = "U"+model
  when /E[3,4,6]8[1,0]0/
    header = "SunFire"+model.gsub(/E/,"")
  when /SUNBLADE[0-9]/
    header = "SunBlade"+model.gsub(/SUNBLADE/,"")
  when /B[0-9]/
    header = "SunBlade"+model.gsub(/B/,"")
  when /T[1,2,5][0-9][0-9][0-9]|M[3,4,5,8,9]000/
    header = "SE_"+model
  when /X2-4/
    header = "SunFireX4470_M2"
  when /X3-4/
    header = "SunFireX4470_M3"
  when /X3-2$/
    header = "SunFireX4170_M3"
  when /X3-2L/
    header = "SunFireX4270_M3"
  else
    header = model
  end
  header = header.gsub(/-/,"_")
  return header
end

# Get header for handbook file

def get_manual_handbook_header(model)
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
