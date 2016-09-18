# Common code

# Store all info in a hash

$exp_info = {}

# Global variables

$exp_id   = ""
$exp_key  = ""
$exp_file = ""

# Check for pigz to accelerate decompression

$gzip_bin = %x[which pigz].chomp

# Set up some script related variables

$methods_dir     = ""
$information_dir = ""
$firmware_dir    = ""
$partner_logo    = ""
$partner_name    = ""
$partner_address = ""
$partner_city    = ""

# Set up script dir

script_dir = File.basename($0)
if !script_dir.match(/\//)
  script_dir = Dir.pwd
end

# Set up directories

$data_dir     = script_dir+"/data"
$handbook_dir = $data_dir+"/handbook"
$fact_dir     = $data_dir+"/facters"
$decode_dir   = $data_dir+"/dmidecode"
$info_dir     = $data_dir+"/information"
$images_dir   = $data_dir+"/images"
$ssl_dir      = script_dir+"/ssl"

# Create directories

[ $data_dir, $images_dir, $handbook_dir, $fact_dir, $decode_dir, $info_dir, $ssl_dir ].each do |test_dir|
  if !File.directory?(test_dir) and !File.symlink?(test_dir) and !File.exist?(test_dir)
    puts "Cannot locate "+test_dir+" directory ("+test_dir+")"
    puts "Creating "+test_dir+" directory ("+test_dir+")"
    Dir.mkdir(test_dir)
  end
end

# Set up PCI ID information

$pci_ids_url  = "http://pci-ids.ucw.cz/v2.2/pci.ids"
$pci_ids_file = script_dir+"/information/pci.ids"

$pci_ids = []

if File.exist?($pci_ids_file)
  $pci_ids = File.readlines($pci_ids_file)
end

# Set global variables

$work_dir      = ""
$verbose       = 0
$nocheck       = 0
$base_dir      = ""
$do_disks      = 0
$host_info     = {}
$sys_config    = {}
$exp_file_list = []
$masked        = 0
$exp_file      = ""
$exp_dir       = ""

# Get script name

def get_code_name()
  code_name = $0
  code_name = Pathname.new(code_name)
  code_name = code_name.basename.to_s
  code_name = code_name.gsub(".rb","")
  return code_name
end

$script_name = get_code_name()

# Get version of script

def get_code_ver()
  code_ver = IO.readlines($0)
  code_ver = code_ver.grep(/^# Version/)
  code_ver = code_ver[0].to_s.split(":")
  code_ver = code_ver[1].to_s.gsub(" ","")
  return code_ver
end

# Extend string class to remove non ascii chars

class String
  def remove_non_ascii
    require 'iconv'
    Iconv.conv('ASCII//IGNORE', 'UTF8', self)
  end
end

# Extend string class to remove control chars

class String
  def strip_control_characters
    self.chars.reject { |char| char.ascii_only? and (char.ord < 32 or char.ord == 127) }.join
  end
end

# Extend Array class to provide padding

class Array
  def pad_right(s, char=nil)
    self + [char] * (s - size) if (size < s)
  end
  def pad_left(s, char=nil)
    (size < s) ? [char] * (s - size) + self : self
  end
end

# Get version

def get_version()
  file_array = IO.readlines $0
  version    = file_array.grep(/^# Version/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  packager   = file_array.grep(/^# Packager/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  name       = file_array.grep(/^# Name/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  return version,packager,name
end

# Print script version information

def print_version()
  (version,packager,name) = get_version()
  puts name+" v. "+version+" "+packager
  exit
end

# Check local config

def check_local_config()
  os_name = %x[uname -a]
  if !os_name.match(/SunOS/)
    $tar_bin = %x[which star].chomp
    if !$tar_bin.match(/star/) or $tar_bin.match(/no star/)
      if $verbose_mode == 1
        puts "S tar not installed"
      end
      if os_name.match(/Darwin/)
        brew_bin = %x[which brew]
        if brew_bin.match(/brew/)
          puts "Installing S tar"
          %x[brew install star]
        else
          puts "Cannot find S tar"
          puts "S tar is required"
          exit
        end
      else
        if !$tar_bin.match(/star/)
          puts "Cannot find S tar"
          puts "S tar is required"
        end
      end
    end
  else
    $tar_bin = %x[which star].chomp
    if !$tar_bin.match(/star/) or $tar_bin.match(/no star/)
      if $verbose_mode == 1
        puts "Using tar"
      end
      $tar_bin = "/usr/bin/tar"
    end
  end
  if !$gzip_bin.match(/pigz/)
    if $verbose_mode == 1
      puts "Parallel GZip (pigz) not installed"
    end
    if os_name.match(/Darwin/)
      brew_bin = %x[which brew]
      if brew_bin.match(/brew/) and !brew_bin.match(/no brew/)
        puts "Installing Parallel GZip"
        %x[brew install pigz]
      else
        $gzip_bin = %x[which gzip].chomp
        if !$gzip_bin.match(/gzip/) or $gzip_bin.match(/no gzip/)
          puts "Cannot find gzip"
          exit
        else
          if $verbose_mode == 1
            puts "Using gzip"
          end
        end
      end
    else
      $gzip_bin = %x[which gzip].chomp
      if !$gzip_bin.match(/gzip/) or $gzip_bin.match(/no gzip/)
        puts "Cannot find gzip"
        exit
      else
        if $verbose_mode == 1
          puts "Using gzip"
        end
      end
    end
  end
  return
end

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
    if !sys_model
      sys_model = "Unknown"
    else
      if !sys_model.to_s.match(/[A-Z]|[a-z]|[0-9]/)
        sys_model = "Unknown"
      else
        sys_model  = sys_model[0]
        sys_model  = sys_model.split(": ")
        sys_model  = sys_model[1]
      end
    end
    if !sys_model.match(/[a-z]/)
      sys_model = "Unknown" 
    end
    if sys_model.match(/VMware/)
      sys_model = "VMware"
    else
      sys_model  = sys_model.chomp
      sys_model  = sys_model.gsub("sun4u","")
      sys_model  = sys_model.gsub("sun4v","")
      sys_model  = sys_model.gsub(/^ /,"")
      sys_model  = sys_model.gsub(/\s+/," ")
      sys_model  = sys_model.gsub(/ Server$/,"")
      if sys_model.match(/^[2,4,6]50/)
        sys_model = "E"+sys_model
      end
    end
    if sys_model.match(/To Be Filled By/)
      sys_model = "O.E.M."
    end
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
      if model_name.match(/Server Module$/)
        model_name = model_name.split(/ /)[-3]
      else
        model_name = model_name.split(/ /)[-1]
      end
    end
  else
    model_name = $sys_config["model"]
  end
  if model_name.match(/^[2,4,6]50/)
    model_name = "E"+model_name
  end
  if !model_name
    model_name = "Unknown"
  end
  if model_name.match(/^T200$/)
    model_name = "T2000"
  end
  return model_name
end

# Check valid report type

def check_valid_report_type(report_name)
  counter  = 0
  position = 0
  valid    = 0
  if !report_name.match(/all/)
    valid_report_list = get_full_report_list()
    valid_report_list.each do |test_name|
      if test_name == report_name
        valid = 1
      end
    end
    if valid == 0
      puts
      puts "Invalid report type: "+$report_type
      puts
      puts "Valid reports:"
      puts
      list_length = valid_report_list.length
      valid_report_list.each do |report_name|
        position = position + report_name.length + 1
        if position > 70
          print "\n"
          position = 0
        end
        counter = counter + 1
        if counter < list_length
          print report_name+", "
        else
          print report_name
        end
      end
      puts
      exit
    end
  end
  return
end

# Get header for handbook file

def get_handbook_header(model)
  model = model.gsub(/Sun Microsystems /,"")
  model = model.gsub(/Sun Fire /,"")
  model = model.gsub(/Oracle Corporation /,"")
  model = model.gsub(/SPARC Enterprise /,"")
  model = model.gsub(/M2$/,"_M2")
  model = model.gsub(/SPARC /,"")
  model = model.gsub(/Sun Blade /,"")
  case model
  when /^480R|^V120/
    model  = model.split(/\s+/)[0].gsub(/V|R/,"")
    header = "SunFireV"+model
  when /^T200$/
    header = "SunFireT2000"
  when /^280R/
    model  = model.split(/\s+/)[0]
    header = "SunFire"+model
  when /Sun Enterprise [0-9][0-9][0-9] /
    header = "E"
    model  = model.split(/\s+/)[2]
    header = "E"+model
  when /^M[0-9][0-9][0-9][0-9]/
    header = "SE_"+model
  when /X[2,4][0-9][0-9][0-9]/
    model  = model.split(/\s+/)[0]
    header = "SunFire"+model
  when /^N/
    header = "Netra_"+model.gsub(/^N/,"")
  when /^V|K$/
    header = "SunFire"+model
  when /X6[0-9][0-9][0-9]|X8[0-9][0-9][0-9]|T6[0-9][0-9][0-9]/
    model  = model.split(/\s+/)[0]
    header = "SunBlade"+model
  when /T3-|T4-|T5-|T6-|T7-|M10-|M5-|M6-|M7-/
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
