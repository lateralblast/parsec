# Code for creating image pages for webserver

def process_photos()
  if !$output_format.match(/serverhtml/)
    return
  end
  counter = 0
  table   = []
  model   = get_sys_model()
  header  = get_handbook_header(model)
  photos_dir = $base_dir+"/photos"
  image_names = [ "Front", "Front Open", "Top", "Top Open", "Left", "Left Open", "Right", "Right Open", "Rear", "Rear Open", "Service", "Service View", "EXT service", "ext service", "service" ]
  image_views = [ "Zoom", "Callout", "Label", "label", "_" ]
  image_names.each do |image_name|
    image_views.each do |image_view|
      if image_name.match(/Service|service/) and header.match(/_[1-8]$/)
        prefix = header.split(/_/)[0..-2].join("_")
        suffix = header.split(/_/)[-1]
        header = prefix+"-"+suffix
      end
      if image_view.match(/_/)
        jpg_file   = header+"_"+image_name.gsub(/ /,"")+".jpg"
        gif_file   = header+"_"+image_name.gsub(/ /,"")+".gif"
        photo_name = image_name.gsub(/FrontOpen/,"Front Open").capitalize
      else
        jpg_file   = header+"_"+image_name.gsub(/ /,"").gsub(/Service/,"_Service").gsub(/service/,"_service")+"_"+image_view+".jpg"
        gif_file   = header+"_"+image_name.gsub(/ /,"").gsub(/Service/,"_Service").gsub(/service/,"_service")+"_"+image_view+".gif"
        photo_name = image_name.gsub(/FrontOpen/,"Front Open")+" "+image_view
        photo_name = photo_name.capitalize
      end
      jpg_file = jpg_file.gsub(/__/,"_")
      gif_file = gif_file.gsub(/__/,"_")
      test_jpg = photos_dir+"/"+jpg_file
      test_gif = photos_dir+"/"+gif_file
      if File.exist?(test_gif) or File.exist?(test_jpg)
        if File.exist?(test_jpg)
          image_file = test_jpg
          photo_file = jpg_file
        else
          image_file = test_gif
          photo_file = gif_file
        end
        file_type = get_file_type(image_file)
        if file_type.match(/jpeg|gif/)
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
      end
    end
  end
  if counter == 0
    table = handle_output("\n")
    table = handle_output("No hardware views exist\n")
  else
    table.push("</table>\n")
  end
  return table  
end