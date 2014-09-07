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
  pdf = create_front_page_background(pdf)
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

def create_front_page_footer(pdf,file_name)
  # Set font to Calibri
  font_name = "Calibri"
  pdf.font font_name
  font_size = $default_font_size
  # Get date
  time = Time.new
  # Set Document Date, Version, and Number
  short_year      = time.year.to_s[2..3]
  date_string     = "#{time.day}/#{time.month}/#{short_year}"
  version_string  = "0.1"
  dir_name        = `pwd`
  dir_name        = Pathname.new(dir_name)
  customer_name   = dir_name.basename.to_s.capitalize
  dir_string      = dir_name.basename.to_s.chop.upcase
  file_string     = file_name.upcase
  document_string = dir_string+"-"+file_string
  # place while strip across bottom of page
  pdf = create_bounding_box(pdf, pdf.bounds.left-5, pdf.bounds.bottom+font_size*2, pdf.bounds.width+5,
    $white, 0, pdf.bounds.width+5, font_size*2+2, $white)
  # Place issue date in bottom left corner
  pdf.fill_color $black
  text_string = "Date #{date_string}"
  pdf.draw_text text_string, :at => [pdf.bounds.left,pdf.bounds.bottom+font_size], :size => font_size
  # Get size of text in pixel from TTF font so we can place text in middle of page
  # Place issue number in bottom middle
  text_string       = "Version: #{version_string}"
  ttf_string_length = get_ttf_string_length(pdf,font_size,text_string)
  pdf.draw_text text_string, :at => [(pdf.bounds.width-ttf_string_length)/2,pdf.bounds.bottom+font_size], :size => font_size
 # Place document number in bottom right
  text_string       = "Document: #{document_string}"
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
  pdf = create_bounding_box(pdf, pdf.bounds.left, pdf.bounds.bottom+200, pdf.bounds.width,
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
  pdf = create_font_page_header(pdf)
  # create a transparent bounding box in middle of cover and put text into it
  pdf = create_font_page_title(pdf,document_title)
  # create prepared by box
  pdf = create_front_page_preparedby(pdf,customer_name)
  # create front page footer
  pdf = create_front_page_footer(pdf,file_name)
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

if $output_mode == "pdf"
  generate_pdf(pdf,document_title,output_file,customer_name)
end