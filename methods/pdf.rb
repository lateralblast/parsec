# PDF report

# Setup fonts

def setup_fonts(pdf)
  pdf.font_families.update(
    "Calibri" => {  :bold        => "fonts/CALIBRIB.TTF",
                    :italic      => "fonts/CALIBRII.TTF",
                    :bold_italic => "fonts/CALIBRIZ.TTF",
                    :normal      => "fonts/CALIBRI.TTF" })

  pdf.font_families.update(
    "Cambria" => {  :bold        => "fonts/CAMBRIAB.TTF",
                    :italic      => "fonts/CAMBRIAI.TTF",
                    :bold_italic => "fonts/CAMBRIAZ.TTF",
                    :normal      => "fonts/CAMBRIA.TTF" })
  return pdf
end

# Setup colours
# Colours from here:
# http://www.computerhope.com/htmcolor.htm

def setup_colors
  $blue        = "0000FF"
  $dark_blue   = "0000A0"
  $cover_blue  = "15317E"
  $white       = "FFFFFF"
  $black       = "000000"
  $red         = "FF0000"
  $light_green = "00FF00"
  $green       = "009900"
  $light_gray  = "F2F2F2"
  $gray        = "DDDDDD"
  $dark_gray   = "333333"
  $brown       = "A4441C"
  $orange      = "F28157"
  $light_gold  = "FBFBBE"
  $dark_gold   = "EBE389"
end

def create_bounding_box(pdf, bb_x, bb_y, bb_width,
  bb_bg_colour, bb_padding, bb_cell_width,
  bb_cell_height, bb_border_color)

  pdf.bounding_box([bb_x,bb_y], :width => bb_width) do
    pdf.cell  :background_color => bb_bg_colour,
              :width            => bb_width,
              :height           => bb_cell_height,
              :border_color     => bb_border_color
  end
  return pdf
end

def create_front_page_background(pdf)
  front_page_image = "images/lb_sphere_1.jpg"
  pdf.image front_page_image, :at => [ 0, pdf.bounds.height ], :height => pdf.bounds.height, :width => pdf.bounds.width
  return pdf
end

def create_font_page_header(pdf)
  # set font to Calibri
  pdf.font "Calibri"
  # put background image on page
  create_front_page_background(pdf)
  # put a white block across the top of the page
  create_bounding_box(pdf, pdf.bounds.left, pdf.bounds.height, pdf.bounds.width,
    $white, 0, pdf.bounds.width, 30, $white)
  if $partner_name.match(/[A-Z]|[a-z]|[0-9]/)
    pdf.fill_color $black
    partner_name_length = get_ttf_string_length(pdf,34,$partner_name)
    pdf.draw_text $partner_name, :at => [pdf.bounds.right-partner_name_length, pdf.bounds.height-23], :size => 34
  else
    pdf.fill_color $blue
    pdf.draw_text "Lateral", :at => [pdf.bounds.right-270, pdf.bounds.height-23], :size => 34
    pdf.fill_color $red
    pdf.draw_text "Blast", :at => [pdf.bounds.right-170, pdf.bounds.height-23], :size => 34
    pdf.fill_color $black
    pdf.draw_text "Pty Ltd", :at => [pdf.bounds.right-93, pdf.bounds.height-23], :size => 34
  end
  # put logo in top left corner
  if $partner_logo.match(/[A-Z]|[a-z]|[0-9]/)
    logo = $partner_logo
  else
    logo = "images/LB_50.png"
  end
  pdf.image logo, :at => [pdf.bounds.left,pdf.bounds.height], :scale => 0.225
  return pdf
end

def get_ttf_string_length(pdf,font_size,text_string)
  ttf_string_length = pdf.width_of(text_string,:size => font_size)
  return(ttf_string_length)
end

def get_ttf_string_height(pdf,font_size,text_string)
  ttf_string_height = pdf.height_of(text_string,:size => font_size)
  return(ttf_string_height)
end

def create_font_page_title(pdf,document_title)
  pdf.transparent(0.7) do
    # Set font to Cambria for title
    font_name = "Cambria"
    pdf.font font_name
    font_size = 60
    # If the Title includes a : split it into two lines
    if document_title.match(/:/)
      height = 2.25*font_size
      (document_title,document_subtitle)=document_title.split(": ")
      document_title = document_title+":"
    else
      document_subtitle = ""
      height = 1.5*font_size
    end
    # Get size of text in pixel from TTF font so we can place text in middle of page
    ttf_string_length = get_ttf_string_length(pdf,font_size,document_title)
    # create a bounding box
    create_bounding_box(pdf, pdf.bounds.left, pdf.bounds.height/2+height/2, pdf.bounds.width,
      $black, 0, pdf.bounds.width, height, $white)
    # put title in middle of page
    pdf.fill_color $white
    if document_subtitle.match(/[A-z]/)
      pdf.draw_text document_title, :at => [(pdf.bounds.width-ttf_string_length)/2,pdf.bounds.height/2+height/2-font_size+10], :size => font_size
      ttf_string_length = get_ttf_string_length(pdf,font_size,document_subtitle)
      pdf.draw_text document_subtitle, :at => [(pdf.bounds.width-ttf_string_length)/2,pdf.bounds.height/2-height/2+font_size/2-10], :size => font_size
    else
      pdf.draw_text document_title, :at => [(pdf.bounds.width-ttf_string_length)/2,pdf.bounds.height/2+height/2-font_size], :size => font_size
    end
  end
  return pdf
end

def create_front_page_footer(pdf,file_name,customer_name)
  # Set font to Calibri
  font_name = "Calibri"
  pdf.font font_name
  font_size = $default_font_size
  # Get date
  time = Time.new
  # Set Document Date, Version, and Number
  year    = time.year.to_s[2..3]
  date    = "#{time.day}/#{time.month}/#{year}"
  version = get_code_ver()
  if customer_name.match(/[A-z]/)
    file = customer_name+"/"+File.basename(file_name)
  else
    file = File.basename(file_name)
  end
  # place while strip across bottom of page
  create_bounding_box(pdf, pdf.bounds.left-5, pdf.bounds.bottom+font_size*2, pdf.bounds.width+5,
    $white, 0, pdf.bounds.width+5, font_size*2+2, $white)
  # Place issue date in bottom left corner
  pdf.fill_color $black
  text_string = "Date #{date}"
  pdf.draw_text text_string, :at => [pdf.bounds.left,pdf.bounds.bottom+font_size], :size => font_size
  # Get size of text in pixel from TTF font so we can place text in middle of page
  # Place issue number in bottom middle
  text_string       = "Version: #{version}"
  ttf_string_length = get_ttf_string_length(pdf,font_size,text_string)
  pdf.draw_text text_string, :at => [(pdf.bounds.width-ttf_string_length)/2,pdf.bounds.bottom+font_size], :size => font_size
 # Place document number in bottom right
  text_string       = "Document: #{file}"
  ttf_string_length = get_ttf_string_length(pdf,font_size,text_string)
  pdf.draw_text text_string, :at => [pdf.bounds.right-ttf_string_length,pdf.bounds.bottom+font_size], :size => font_size
  return pdf
end

def create_front_page_preparedby(pdf,customer_name)
  font_name = "Calibri"
  pdf.font font_name
  pdf.fill_color $white
  login        = Etc.getlogin
  creator_name = Etc.getpwnam(login).gecos.split(/,/).first
  # put a blue box on the bottom of the page
  create_bounding_box(pdf, pdf.bounds.left, pdf.bounds.bottom+200, pdf.bounds.width,
    $cover_blue, 0, pdf.bounds.width, 175, $cover_blue)
  # create prepared for box
  font_size   = 30
  text_string = "Prepared for:"
  pdf.draw_text text_string, :at => [pdf.bounds.left+10,pdf.bounds.bottom+200-font_size], :size => font_size
  # create prepared for box
  font_size   = 15
  text_string = "Prepared by:"
  pdf.draw_text text_string, :at => [pdf.bounds.left+10,pdf.bounds.bottom+100-font_size], :size => font_size
  # create customer box
  font_size   = 30
  text_string = customer_name
  pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+200-font_size], :size => font_size
  # create lateral box
  font_size   = 15
  text_string = "#{creator_name}"
  pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+100-font_size], :size => font_size
  if $partner_name.match(/[A-Z]|[a-z]|[0-9]/)
    text_string = $partner_name
    pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+100-font_size*2], :size => font_size
    if $partner_address.match(/[A-Z]|[a-z]|[0-9]/)
      text_string = $partner_address
      pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+100-font_size*3], :size => font_size
    end
    if $partner_city.match(/[A-Z]|[a-z]|[0-9]/)
      text_string = $partner_city
      pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+100-font_size*4], :size => font_size
    end
  else
    text_string = "Lateral Blast Pty Ltd"
    pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+100-font_size*2], :size => font_size
    text_string = "P.O. Box 768"
    pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+100-font_size*3], :size => font_size
    text_string = "South Yarra 3141"
    pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+100-font_size*4], :size => font_size
  end
  return pdf
end

def create_front_page(pdf,document_title,file_name,customer_name)
  # create front page header
  create_font_page_header(pdf)
  # create a transparent bounding box in middle of cover and put text into it
  create_font_page_title(pdf,document_title)
  # create prepared by box
  create_front_page_preparedby(pdf,customer_name)
  # create front page footer
  create_front_page_footer(pdf,file_name,customer_name)
  return pdf
end

def create_footers(pdf,document_title)
  # rest of pages
  font_name = "Calibri"
  pdf.font font_name
  pdf.fill_color $black
  font_size    = $default_font_size
  if $partner_logo.match(/[A-Z]|[a-z]|[0-9]/)
    logo = $partner_logo
  else
    logo = "images/LB_50.png"
  end
  scale_factor = 0.1
  pdf.repeat lambda { |pg| pg != 1 } do
    # footer
    pdf.canvas do
      text_string       = document_title
      ttf_string_length = get_ttf_string_length(pdf,font_size,text_string)
      pdf.draw_text text_string, :at => [(pdf.bounds.width-ttf_string_length)/2,pdf.bounds.bottom+font_size+1], :size => font_size
    end
    (image_width,image_height) = FastImage.size(logo)
    image_width  = image_width*(scale_factor)
    image_height = image_height*scale_factor
    pdf.image logo, :at => [pdf.bounds.left,pdf.bounds.bottom-2-image_height], :scale => scale_factor
  end
  return pdf
end

def create_page_numbers(pdf)
  # Do numbers last otherwise it doesn't enumerate pages
  font_name = "Calibri"
  pdf.font font_name
  pdf.fill_color $black
  font_size = $default_font_size
  pdf.number_pages "<page> of <total>",
    {:start_count_at => 2,
    :page_filter => lambda{ |pg| pg != 1 },
    :at => [pdf.bounds.left, pdf.bounds.bottom-font_size-2],
    :align => :right,
    :size => font_size}
  return pdf
end

def create_table_contents(pdf,toc)
  # Table of Contents
  font_name = "Calibri"
  pdf.font font_name
  pdf.go_to_page(1)
  pdf.start_new_page
  font_size      = 28
  pdf.fill_color = $dark_blue
  pdf.text "Table of Contents\n", size: font_size
  pdf.outline.page :title => "Table of Contents", :destination => 2
  pdf.text " ", size: font_size
  pdf.fill_color = $black
  font_size      = $default_font_size
  toc_length     = toc.length
  toc.each_with_index do |page,index|
  #toc.each_with_index do |(key, value), index|
    (page_title,page_number) = page.split(",")
    if page_title.match(/[A-z]/)
      if toc_length > 52
        page_number = page_number.to_i+3
      else
        page_number = page_number.to_i+2
      end
      dot_length  = get_ttf_string_length(pdf,font_size,".")
      text_length = get_ttf_string_length(pdf,font_size,"#{page_title}  #{page_number}")
      free_space  = pdf.bounds.width-text_length
      no_dots     = free_space/dot_length
      no_dots     = no_dots.to_i-1
      dot_string  = "."*no_dots
      test_string = "#{page_title} #{dot_string} #{page_number}"
      text_string = "<link anchor='#{page_title}'>#{page_title}</link> #{dot_string}"
      text_length = get_ttf_string_length(pdf,font_size,text_string)
      text_height = get_ttf_string_height(pdf,font_size,text_string)
      pdf.outline.page :title => page_title.to_s, :destination => page_number.to_i
      number_length = get_ttf_string_length(pdf,font_size,page_number.to_s)
      number_height = get_ttf_string_height(pdf,font_size,page_number.to_s)
      y_pos = pdf.cursor
      pdf.bounding_box [0, y_pos], :width => text_length, :height => font_size do
        pdf.text_box text_string, :width => text_length, :align => :left, :inline_format => true
      end
      pdf.bounding_box [pdf.bounds.width-number_length, y_pos], :width => number_length, :height => font_size do
        pdf.text_box page_number.to_s, :width => number_length, :align => :right, :inline_format => true
      end
      if y_pos < 20 and index < toc_length
        pdf.start_new_page
      end
    end
  end
  return pdf
end

def create_code_box(pdf,x,y,text_file)
  pdf.font "Courier"
  font_size      = 9
  file_text      = IO.readlines(text_file)
  pdf.fill_color = $dark_gray
  pdf.fill_rectangle [x,y], pdf.bounds.width,file_text.length*(font_size+3)
  pdf.fill_color = $white
  file_text.each do |line|
    text = line.gsub(/\t/," ")
    pdf.move_down(font_size+2)
    pdf.draw_text text, :at => [x+10,pdf.y], size: font_size
  end
  return pdf
end

def line_to_cells(line,section)
  row_data = []
  cells    = line.split("\|")
  cells    = cells[0..-2]
  cell_1   = cells[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
  counter  = 0
  if !cells[2]
    row_data = [cell_1]
  else
    cell_2 = cells[2].gsub(/^\s+/,"").gsub(/\s+$/,"")
    if cell_2.match(/Newer/)
      cell_2 = "<color rgb='#{$red}'>#{cell_2}</color>"
    end
    if !cells[3]
      row_data = [cell_1,cell_2]
    else
      cell_3 = cells[3].gsub(/^\s+/,"").gsub(/\s+$/,"")
      if !cells[4]
        row_data = [cell_1,cell_2,cell_3]
      else
        cell_4 = cells[4].gsub(/^\s+/,"").gsub(/\s+$/,"")
        if cell_4.match(/\*No\*/)
          cell_4 = "<color rgb='#{$red}'>No</color>"
        end
        if cell_4.match(/Yes/)
          cell_4 = "<color rgb='#{$green}'>Yes</color>"
        end
        row_data = [cell_1,cell_2,cell_3,cell_4]
        for item in cells[5..-1]
          item = item.gsub(/^\s+/,"").gsub(/\s+$/,"").gsub(/\[|\]|"/,"")
          if !item.match(/[a-z]|[A-Z]|[0-9]|\./)
            item = ""
          end
          row_data.push(item)
        end
      end
    end
  end
  return row_data
end

def process_handbook_info(pdf,toc,model)
  if !File.directory?($handbook_dir) and !File.symlink($handbook_dir)
    return poc
  end
  toc.push("Support Information,#{pdf.page_count}")
  pdf.start_new_page
  pdf.fill_color = $dark_blue
  pdf.text "Support Information", :size => $section_font_size, :inline_format => true
  pdf.text "\n"
  pdf.fill_color $black
  header     = get_handbook_header(model)
  html_files = Dir.entries($handbook_dir).grep(/#{header}/)
  spec_file  = html_files.grep(/Specifications/)[0]
  list_file  = html_files.grep(/Components/)[0]
  if File.exist?(spec_file)
    toc.push("System Support Information,#{pdf.page_count}")
  end
  return poc
end

def process_model_info(pdf,toc,model)
  header = get_handbook_header(model)
  photos_dir  = $base_dir+"/photos"
  if !File.directory?(photos_dir) and !File.symlink?(photos_dir)
    return toc
  end
  counter = 0
  photo_list = get_photo_list() 
  photo_list.each do |image_info|
    image_name = image_info[0]
    image_file = image_info[1]
    if File.exist?(image_file)
      if $verbose == 1
        handle_output("Processing image: #{image_file}\n")
      end
      if counter == 0
        toc.push("Model Information,#{pdf.page_count}")
        pdf.start_new_page
        pdf.fill_color = $dark_blue
        pdf.text "Model Information", :size => $section_font_size, :inline_format => true
        pdf.text "\n"
        pdf.fill_color $black
        counter = 1
      else
        pdf.start_new_page
      end
      scale = 1
      image_size   = FastImage.size(image_file)
      image_width  = image_size[0]
      page_width   = pdf.bounds.width
      image_height = image_size[1]
      page_height  = pdf.bounds.height
      if image_width > page_width
        scale = (page_width-150) / image_width
        new_image_height = image_height*scale
        if new_image_height > page_height
          scale = (page_height-150) / image_height
        else
          scale = (page_width-150) / image_width
        end
      else
        if image_height > page_height
          scale = (page_height-150) / image_height
          new_image_width = image_width*scale
          if new_image_width > page_width
            scale = (image_width-150) / image_width
          else
            scale = (page_height-150) / image_height
          end
        end
      end
      if image_file.match(/zoom/)
        lq_image_file  = image_file.gsub(/\.jpg/,"_lq.jpg")
        if !File.exist?(lq_image_file)
          image = Image.read(image_file).first
          image.format = "JPEG"
          image.write(lq_image_file) { self.quality = 80 }
        end
      else
        lq_image_file = image_file
      end
    end
    pdf.image lq_image_file, :position => :center, :vposition => :center, :scale => scale
    text_string = "View: "+image_name
    text_width  = get_ttf_string_length(pdf,$default_font_size,text_string)
    x_pos = page_width/2 - text_width/2
    y_pos = page_height/2 - image_height*scale/2 - 30
    pdf.draw_text(text_string, :at => [ x_pos, y_pos ] )
    pdf.add_dest(text_string,pdf.dest_fit(pdf.page))
    toc.push("#{text_string},#{pdf.page_count-1}")
  end
  return toc
end

def generate_pdf(pdf,document_title,output_pdf,customer_name)
  input_file = $output_file
  setup_colors()
  Prawn::Document.generate(output_pdf,:info => {
    :Title        => document_title.gsub(/:/," for"),
    :Author       => $company_name,
    :Subject      => document_title,
    :Keywords     => "Oracle Explorer",
    :Creator      => $author_name,
    :Producer     => $script_name,
    :CreationDate => Time.now
  }) do |pdf|
    setup_fonts(pdf)
    file   = File.basename(output_pdf)
    pdf    = create_front_page(pdf,document_title,file,customer_name)
    pdf    = create_footers(pdf,document_title)
    toc    = []
    lcount = 0
    lines  = IO.readlines(input_file)
    title  = ""
    table  = 0
    model  = ""
    section     = ""
    table_data  = []
    table_row   = []
    table_title = ""
    lines.each do |line|
      next_line = lines[lcount+1]
      sub_section_counter = 0
      if next_line
        if next_line.match(/OBP Information/)
          #pdf.start_new_page
        end
      end
      # Get Model number
      if section.match(/Host Information/)
        if line.match(/Model/)
          cells  = line.split(/\|/)
          cell_1 = cells[1]
          cell_2 = cells[2]
          if cell_1.match(/Model/)
            model = cell_2.gsub(/^\s+|\s+$/,"")
          end
        end
      end
      # If top of table get title, create section head, and add to TOC
      if line.match(/^\+/) and next_line.match(/[A-z]/) and table == 0
        title   = next_line.split("|")[1].gsub(/^\s+|\s+$/,"")
        section = title
        toc.push("#{section},#{pdf.page_count}")
        pdf.start_new_page
        pdf.fill_color = $dark_blue
        pdf.text "#{section}", :size => $section_font_size, :inline_format => true
        pdf.add_dest(section,pdf.dest_fit(pdf.page))
        pdf.text "\n"
        pdf.fill_color $black
        table = 1
      end
      # If reached end of table print it and reset table array
      if line.match(/^\+/) and !next_line.match(/[A-z]/) and table == 1
        pdf.font_size($table_font_size)
        #pdf.fill_color = $blue
        #pdf.text table_title, :size => $table_font_size, :align => :justify
        #pdf.text "\n", :size => $table_font_size, :align => :justify
        pdf.fill_color = $black
        # If line is empty, ie space after table, render table
        pdf.table(table_data, :cell_style => { :inline_format => true }, :width => pdf.bounds.width ) do
          pdf.fill_color = $black
          style(row(0), :background_color => $blue, :text_color => $white)
#          column(0..2).width=pdf.bounds.right/6
#          column(1..2).width=pdf.bounds.right/6*2.5
        end
        table = 0
        title = ""
        pdf.text "\n", :size => $default_font_size, :align => :justify
        pdf.font_size($default_font_size)
        table_data = []
        row_data   = []
        # If we are handling host information, insert hardware information
        if section.match(/Host Information/)
          toc = process_model_info(pdf,toc,model)
        end
        section = ""
      end
      # If not the start or end of the table get the contents of the cell and
      # put them into an array
      if title.match(/\(/)
        title_string = title.gsub(/\(|\)/,"")
        line_string  = line.gsub(/\(|\)/,"")
      else
        title_string = title
        line_string  = line
      end
      if table == 1 and !line.match(/^\+/) and !line_string.match(/#{title_string}/) or line.match(/Complies|Power Supplies|Rack Mounting/)
        row_data = line_to_cells(line,section)
        table_data.push(row_data)
      end
      lcount = lcount+1
    end
    #toc = process_handbook(pdf,toc,model)
    create_table_contents(pdf,toc)
    create_page_numbers(pdf)
  end
  return
end
