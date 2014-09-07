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
  $blue       = "0000FF"
  $dark_blue  = "0000A0"
  $cover_blue = "15317E"
  $white      = "FFFFFF"
  $black      = "000000"
  $red        = "FF0000"
  $green      = "00FF00"
  $light_gray = "F2F2F2"
  $gray       = "DDDDDD"
  $dark_gray  = "333333"
  $brown      = "A4441C"
  $orange     = "F28157"
  $light_gold = "FBFBBE"
  $dark_gold  = "EBE389"
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
  pdf.fill_color $blue
  pdf.draw_text "Lateral", :at => [pdf.bounds.right-270, pdf.bounds.height-23], :size => 34
  pdf.fill_color $red
  pdf.draw_text "Blast", :at => [pdf.bounds.right-170, pdf.bounds.height-23], :size => 34
  pdf.fill_color $black
  pdf.draw_text "Pty Ltd", :at => [pdf.bounds.right-93, pdf.bounds.height-23], :size => 34
  # put logo in top left corner
  logo = "images/LB_50.png"
  pdf.image logo, :at => [pdf.bounds.left,pdf.bounds.height], :scale => 0.225
  return pdf
end

def get_ttf_string_length(pdf,font_size,text_string)
  ttf_string_length = pdf.width_of(text_string,:size => font_size)
  return(ttf_string_length)
end

def get_ttf_string_height(pdf,font_size,text_string)
  ttf_string_length = pdf.height_of(text_string,:size => font_size)
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
  text_string = "Lateral Blast Pty Ltd"
  pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+100-font_size*2], :size => font_size
  text_string = "P.O. Box 768"
  pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+100-font_size*3], :size => font_size
  text_string = "South Yarra 3141"
  pdf.draw_text text_string, :at => [pdf.bounds.width/2+10,pdf.bounds.bottom+100-font_size*4], :size => font_size
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
  logo         = "images/LB_50.png"
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
  pdf.text " ", size: font_size
  pdf.fill_color = $black
  font_size      = $default_font_size
  toc.each do |page|
  #toc.each_with_index do |(key, value), index|
    (page_title,page_number) = page.split(",")
    page_number = page_number.to_i+2
    dot_length  = get_ttf_string_length(pdf,font_size,".")
    text_length = get_ttf_string_length(pdf,font_size,"#{page_title}  #{page_number}")
    free_space  = pdf.bounds.width-text_length
    no_dots     = free_space/dot_length
    no_dots     = no_dots.to_i
    dot_string  = "."*no_dots
    text_string = "#{page_title} #{dot_string} #{page_number}"
    text_length = get_ttf_string_length(pdf,font_size,text_string)
    if text_length < 537.6
      text_string = "#{page_title} #{dot_string}  #{page_number}"
    end
    pdf.text text_string, size: font_size, :align => :right
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

def generate_pdf(pdf,document_title,output_pdf,customer_name)
  input_file = $output_file
  setup_colors()
  Prawn::Document.generate output_pdf do |pdf|
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
      # If top of table get title, create section head, and add to TOC
      if line.match(/^\+/) and next_line.match(/[A-z]/) and table == 0
        title   = next_line.split("|")[1].gsub(/^\s+|\s+$/,"")
        section = title
        toc.push("#{section},#{pdf.page_count}")
        pdf.start_new_page
        pdf.fill_color = $dark_blue
        pdf.text "#{section}", :size => $section_font_size, :inline_format => true
        pdf.text "\n"
        pdf.fill_color $black
        table = 1
      end
      # If reached end of table print it and reset table array
      if line.match(/^\+/) and !next_line.match(/[A-z]/) and table == 1
        pdf.font_size($table_font_size)
        pdf.fill_color = $blue
        pdf.text table_title, :size => $table_font_size, :align => :justify
        pdf.text "\n", :size => $table_font_size, :align => :justify
        pdf.fill_color = $black
        # If line is empty, ie space after table, render table
        pdf.table(table_data) do
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
          toc.push("Model Information,#{pdf.page_count}")
          pdf.start_new_page
          pdf.fill_color = $dark_blue
          pdf.text "Model Information", :size => $section_font_size, :inline_format => true
          pdf.text "\n"
          pdf.fill_color $black
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
          image_names = [ "Front", "Front Open", "Top", "Left Open", "Right Open", "Rear", "Rear Open" ]
          image_names.each do |image_name|
            image_file = $image_dir+"/"+header+"_"+image_name.downcase.gsub(/ /,"")+"_zoom.jpg"
            if File.exist?(image_file)
              scale = 1
              image_size   = FastImage.size(image_file)
              image_width  = image_size[0]
              page_width   = pdf.bounds.width
              image_height = image_size[1]
              page_height  = pdf.bounds.height
              if image_height > page_height
                scale = (page_height-100) / image_height
              else
                if image_width > page_width
                  scale = page_width / image_width
                end
              end
              pdf.image image_file, :position => :center, :vposition => :center, :scale => scale
              text_string = "View: "+image_name
              text_width  = get_ttf_string_length(pdf,$default_font_size,text_string)
              x_pos = page_width/2 - text_width/2
              y_pos = page_height/2 - image_height*scale/2 - 30
              pdf.draw_text(text_string, :at => [ x_pos, y_pos ] )
              current_ypos = pdf.y
              toc.push("#{text_string},#{pdf.page_count}")
              if current_ypos-table_height < 0 or current_ypos < 30
                pdf.start_new_page
              end
            end
          end
        end
        section = ""
      end
      # If not the start or end of the table get the contents of the cell and
      # put them into an array
      if table == 1 and !line.match(/^\+/) and !line.match(/#{title}/)
        cells  = line.split("\|")
        cells  = cells[0..-2]
        cell_1 = cells[1].gsub(/^\s+/,"").gsub(/\s+$/,"")
        if !cells[2]
          row_data = [cell_1]
        else
          cell_2 = cells[2].gsub(/^\s+/,"").gsub(/\s+$/,"")
          if !cells[3]
            row_data = [cell_1,cell_2]
          else
            cell_3 = cells[3].gsub(/^\s+/,"").gsub(/\s+$/,"")
            if !cells[4]
              row_data = [cell_1,cell_2,cell_3]
            else
              cell_4 = cells[4].gsub(/^\s+/,"").gsub(/\s+$/,"")
              row_data = [cell_1,cell_2,cell_3,cell_4]
            end
          end
        end
        table_data.push(row_data)
        if section.match(/Host Information/)
          if cell_1.match(/Model/)
            model = cell_2
          end
        end
      end
      lcount = lcount+1
    end
    create_table_contents(pdf,toc)
    create_page_numbers(pdf)
  end
  return
end
