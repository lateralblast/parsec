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
  image_names = [ "Front", "Front Open", "Top", "Top Open", "Left", "Left Open", "Right", "Right Open", "Rear", "Rear Open" ]
  image_views = [ "Zoom", "Callout" ]
  image_names.each do |image_name|
    image_views.each do |image_view|
      photo_file = header+"_"+image_name.downcase.gsub(/ /,"")+"_"+image_view.downcase+".jpg"
      image_file = photos_dir+"/"+photo_file
      photo_name = image_name+" "+image_view
      if File.exist?(image_file)
        file_type = get_file_type(image_file)
        if file_type.match(/jpeg/)
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