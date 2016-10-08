# Image related code

# the svg name of a file

def get_svg_file(exp_model)
  svg_dir  = $base_dir+"/public/images"
  svg_file = svg_dir+"/"+exp_model.downcase.gsub(/-| /,"_")+"_front.svg"
  return svg_file
end

# Create a list of photo images 

def get_photo_list()
  model       = get_sys_model()
  header      = get_handbook_header(model)
  sub_dir     = ""
  photo_list  = []
  photos_dir  = $base_dir+"/photos"
  dir_list    = Dir.entries(photos_dir)
  image_names = [ "Front", "Front Open", "front_open", "Top", "Top Open", "Left", "Left Open", "Right", "Right Open", "Rear", "Rear Open", "Service", "Service View", "EXT service" ]
  image_views = [ "Zoom", "Callout", "Label", "label", "_" ]
  image_names.each do |image_name|
    image_views.each do |image_view|
      if image_name.match(/Service|service/) and header.match(/_[1-8]$/)
        prefix = header.split(/_/)[0..-2].join(" ")
        suffix = header.split(/_/)[-1]
        header = prefix+"-"+suffix
      end
      if image_view.match(/_/)
        jpg_file    = header+"_"+image_name.gsub(/ /,"")+".jpg"
        jpg_file_lc = header+"_"+image_name.downcase.gsub(/ /,"")+".jpg"
        photo_name  = image_name.gsub(/FrontOpen/,"Front Open").capitalize
      else
        jpg_file    = header+"_"+image_name.gsub(/ /,"").gsub(/Service/,"_Service").gsub(/service/,"_service")+"_"+image_view+".jpg"
        jpg_file_lc = header+"_"+image_name.downcase.gsub(/ /,"").gsub(/Service/,"_Service").gsub(/service/,"_service")+"_"+image_view.downcase+".jpg"
        photo_name  = image_name.gsub(/FrontOpen/,"Front Open")+" "+image_view
        photo_name  = photo_name.capitalize
      end
      jpg_file    = jpg_file.gsub(/__/,"_")
      jpg_file_lc = jpg_file_lc.gsub(/__/,"_")
      case  header
      when /^c/
        sub_dir = "c-series"
      when /lade/
        sub_dir = "blade"
      when /^E|SunFire[2,3,4,6]8|E25/
        sub_dir = "e-series"
      when /PCI/
        sub_dir = "iou"
      when /SE_M|SPARC_M|flat/
        sub_dir = "m-series"
      when /Netra/
        sub_dir = "netra"
      when /SPARC_S/
        sub_dir = "s-series"
      when /SE_T|SPARC_T|SunFireT|sparc-t/
        sub_dir = "t-series"
      when /^U/
        sub_dir = "ultra"
      when /FunFire8|SunFireV/
        sub_dir = "v-series"
      when /^W/
        sub_dir = "workstation"
      when /^L|^OA|^OD|^OV|Server_X|SunFireX|^X|sparc-x/
        sub_dir = "x-series"
      when /^Z/
        sub_dir = "z-series"
      else
        sub_dir = "other"
      end
      test_jpg    = photos_dir+"/"+sub_dir+"/"+jpg_file
      test_jpg_lc = photos_dir+"/"+sub_dir+"/"+jpg_file_lc
      test_files  = [ test_jpg, test_jpg_lc ]
      used_files  = []
      test_files.each do |image_file|
        test_file = File.basename(image_file)
        test_file = test_file.downcase
        if !used_files.to_s.match(/#{test_file}/)
          if File.exist?(image_file)
            file_type = get_file_type(image_file)
            if file_type.match(/jpeg/)
              photo_list.push([photo_name,image_file])
              used_files.push(test_file)
            end
          end
        end
      end
    end
  end
  return photo_list
end

# Code for creating image pages for webserver or PDF generation

def process_photos()
  if !$output_format.match(/serverhtml/)
    return
  end
  counter    = 0
  table      = []
  photo_list = get_photo_list() 
  photo_list.each do |image_info|
    photo_name = image_info[0]
    image_file = image_info[1]
    photo_file = File.basename(image_file)
    if counter == 0
      table.push("<h1>Server Views</h1>\n")
      table.push("<table border=\"1\">\n")
      table.push("<tr>\n")
      table.push("<th>View</th>\n")
      table.push("</tr>\n")
    end
    counter = counter + 1
    table.push("<tr><td><a href=\"/photos?image=#{photo_file}\">#{photo_name}</a></td></tr>\n")
  end
  if counter == 0
    table = handle_output("\n")
    table = handle_output("No hardware views exist\n")
  else
    table.push("</table>\n")
  end
  return table  
end
