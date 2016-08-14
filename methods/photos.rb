# Code for creating image pages for webserver

def get_photo_list()
  model       = get_sys_model()
  header      = get_handbook_header(model)
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
        gif_file    = header+"_"+image_name.gsub(/ /,"")+".gif"
        gif_file_lc = header+"_"+image_name.downcase.gsub(/ /,"")+".gif"
        photo_name  = image_name.gsub(/FrontOpen/,"Front Open").capitalize
      else
        jpg_file    = header+"_"+image_name.gsub(/ /,"").gsub(/Service/,"_Service").gsub(/service/,"_service")+"_"+image_view+".jpg"
        jpg_file_lc = header+"_"+image_name.downcase.gsub(/ /,"").gsub(/Service/,"_Service").gsub(/service/,"_service")+"_"+image_view.downcase+".jpg"
        gif_file    = header+"_"+image_name.gsub(/ /,"").gsub(/Service/,"_Service").gsub(/service/,"_service")+"_"+image_view+".gif"
        gif_file_lc = header+"_"+image_name.downcase.gsub(/ /,"").gsub(/Service/,"_Service").gsub(/service/,"_service")+"_"+image_view.downcase+".gif"
        photo_name  = image_name.gsub(/FrontOpen/,"Front Open")+" "+image_view
        photo_name  = photo_name.capitalize
      end
      jpg_file    = jpg_file.gsub(/__/,"_")
      jpg_file_lc = jpg_file_lc.gsub(/__/,"_")
      gif_file    = gif_file.gsub(/__/,"_")
      gif_file_lc = gif_file_lc.gsub(/__/,"_")
      test_jpg    = photos_dir+"/"+jpg_file
      test_jpg_lc = photos_dir+"/"+jpg_file_lc
      test_gif    = photos_dir+"/"+gif_file
      test_gif_lc = photos_dir+"/"+gif_file_lc
      test_files  = [ test_jpg, test_jpg_lc, test_gif, test_gif_lc ]
      test_files.each do |image_file|
        test_dir  = Pathname.new(image_file)
        test_file = File.basename(image_file)
        if dir_list.to_s.match(/#{test_file}/)
          file_type = get_file_type(image_file)
          if file_type.match(/jpeg|gif/)
            photo_list.push([photo_name,image_file])
          end
        end
      end
    end
  end
  return photo_list
end

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
