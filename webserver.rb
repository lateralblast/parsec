#!/usr/bin/env ruby

# Name:         parsec webserver (Explorer Parser)
# Version:      0.1.9
# Release:      1
# License:      CC-BA (Creative Commons By Attribution)
#               http://creativecommons.org/licenses/by/4.0/legalcode
# Group:        System
# Source:       N/A
# URL:          http://lateralblast.com.au/
# Distribution: UNIX
# Vendor:       Lateral Blast
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  Ruby script for processing explorer

# Load required gems

require 'rubygems'
require 'pathname'
require 'etc'
require 'date'
require 'socket'

def install_gem(gem_name)
  puts "Information:\tInstalling #{gem_name}"
  %x[gem install #{gem_name}]
  Gem.clear_paths
  return
end

begin
  require 'sinatra'
rescue LoadError
  install_gem("sinatra")
end
begin
  require 'fileutils'
rescue LoadError
  install_gem("fileutils")
end
begin
  require 'hex_string'
rescue LoadError
  install_gem("hex_string")
end
begin
  require 'unpack'
rescue LoadError
  install_gem("unpack")
end
begin
  require 'enumerate'
rescue LoadError
  install_gem("enumerate")
end
begin
  require 'iconv'
rescue LoadError
  install_gem("iconv")
end
begin
  require 'bcrypt'
rescue LoadError
  install_gem("bcrypt")
end
begin
  require 'fileutils'
rescue LoadError
  install_gem("fileutils")
end

# Some webserver defaults

default_bind       = "127.0.0.1"
default_exceptions = false
default_port       = "9494"
default_sessions   = "true"
default_errors     = "false"
enable_ssl         = true
enable_auth        = false
enable_upload      = false
ssl_certificate    = "ssl/cert.crt"
ssl_key            = "ssl/pkey.pem"
$ssl_password      = "123456"

# Get front end IP

frontend_ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
frontend_ip = frontend_ip.ip_address

# Only allow uploads if we has authentication

if !enable_auth == true
  enable_upload = false
end

set :port,            default_port
set :bind,            frontend_ip
set :sessions,        default_sessions
set :dump_errors,     default_errors
set :show_exceptions, default_exceptions

# Load methods

if Dir.exist?("./methods")
  file_list = Dir.entries("./methods")
  for file in file_list
    if file =~ /rb$/
      require "./methods/#{file}"
    end
  end
end

# SSL config

if enable_ssl == true
  require 'webrick/ssl'
  require 'webrick/https'
  if !File.directory?($ssl_dir)
    puts "Information: Creating "+$ssl_dir
    Dir.mkdir($ssl_dir)
  end
  if !File.exist?(ssl_certificate) or !File.exist?(ssl_key)
    %x[openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout #{ssl_key} -out #{ssl_certificate}]
  end
  set :ssl_certificate, ssl_certificate
  set :ssl_key, ssl_key
  module Sinatra
    class Application
      def self.run!
        certificate_content = File.open(ssl_certificate).read
        key_content = File.open(ssl_key).read
  
        server_options = {
          :Host => bind,
          :Port => port,
          :SSLEnable => true,
          :SSLCertificate => OpenSSL::X509::Certificate.new(certificate_content),
          :SSLPrivateKey => OpenSSL::PKey::RSA.new(key_content,$ssl_password)
        }
  
        Rack::Handler::WEBrick.run self, server_options do |server|
          [:INT, :TERM].each { |sig| trap(sig) { server.stop } }
          server.threaded = settings.threaded if server.respond_to? :threaded=
          set :running, true
        end
      end
    end
  end
end

# htpasswd authentication

# Set up global files

$htpasswd_file = Dir.pwd+"/views/.htpasswd"

if enable_auth == true
  module Sinatra
    class Application
    
      helpers do
        def protect!
          unless authorized?
            response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
            throw(:halt, [401, "Not authorized\n"])
          end
        end
  
        def authorized?
          @auth ||=  Rack::Auth::Basic::Request.new(request.env)
          passwd = File.open($htpasswd_file).read.split("\n").map {|credential| credential.split(':')}
          if @auth.provided? && @auth.basic? && @auth.credentials
            user, pass = @auth.credentials
            auth = passwd.assoc(user)
            crypt = BCrypt::Password.create(auth[1])
            return false unless auth
            [user, crypt] == auth
          end
        end
      end
    end
  end
end

# setup config

check_local_config()

# Set global variables
# Set defaults
# Unlike the reporting script, these currently don't get auto detected

def set_global_vars()
  $work_dir      = "/tmp"
  $output_format = "serverhtml"
  $output_file   = ""
  $script_name   = "Parsec"
  $verbose       = 0
  $base_dir      = Dir.pwd
  $do_disks      = 0
  $exp_file_list = []
  $masked        = 0
  $exp_file      = ""
  $exp_dir       = $base_dir+"/explorers"
  $work_dir      = "/tmp"
end

set_global_vars()

before do
  check_local_config()
  set_global_vars()
end

# Enable uploads

if enable_upload == true
  include FileUtils::Verbose

  get '/upload' do
    if enable_auth == true
      protect!
    end
    head  = File.readlines("./views/layout.html")
    body  = File.readlines("./views/upload.html")
    array = head + body
    array = array.join("\n")
    "#{array}"
  end

  post '/upload' do
    if enable_auth == true
      protect!
    end
    tempfile = params[:file][:tempfile] 
    filename = params[:file][:filename] 
    if filename.match(/explorer/) and filename.match(/gz$/)
      FileUtils.copy(tempfile.path, "#{$exp_dir}/#{filename}")
    else
      redirect '/help'
    end
    redirect '/list'
  end
end

# handle error - redirect to help

error do
  head  = File.readlines("./views/layout.html")
  body  = File.readlines("./views/help.html")
  array = head + body
  array = array.join("\n")
  "#{array}"
end

# handle /

get '/' do
  head  = File.readlines("./views/layout.html")
  body  = File.readlines("./views/help.html")
  array = head + body
  array = array.join("\n")
  "#{array}"
end

# handle 404

not_found do
  head  = File.readlines("./views/layout.html")
  body  = File.readlines("./views/help.html")
  array = head + body
  array = array.join("\n")
  "#{array}"
end

# List explorers

get '/list' do
  $host_info  = {}
  $sys_config = {}
  if enable_auth == true
    protect!
  end
  if params['example']
    $exp_dir = Dir.pwd+"/examples"
  else
    $exp_dir = Dir.pwd+"/explorers"
  end
  if params['masked']
    if params['masked'].to_s.downcase.match(/true|1/)
      $masked = 1
    else
      $masked = 0
    end
  else
    $masked = 0
  end
  if params['report']
    $report_type = params['report']
  else
    $report_type = "all"
  end
  if params['model']
    search_model = params['model']
  else
    search_model = ""
  end
  if params['date']
    search_date  = params['date']
  else
    search_date = ""
  end
  if params['year']
    search_year  = params['year']
  else
    search_year = ""
  end
  if params['server']
    search_name  = params['server']
  else
    search_name = ""
  end
  if params['search']
    search_param = params['search']
  else
    search_param = ""
  end
  if params['value']
    search_value = params['value']
  else
    search_value = ""
  end
  head  = File.readlines("./views/layout.html")
  body  = list_explorers(search_model,search_date,search_year,search_name,search_param,search_value)
  array = head + body
  array = array.join("\n")
  "#{array}"
end

# Do report

get '/report' do
    if enable_auth == true
    protect!
  end
  if params['example']
    $exp_dir = Dir.pwd+"/examples"
  else
    $exp_dir = Dir.pwd+"/explorers"
  end
  if params['masked']
    if params['masked'].to_s.downcase.match(/true|1/)
      $masked = 1
    else
      $masked = 0
    end
  else
    $masked = 0
  end
  if params['report']
    $report_type = params['report']
  else
    $report_type = "all"
  end
  if params['model']
    $search_model = params['model']
  else
    $search_model = ""
  end
  if params['date']
    $search_date  = params['date']
  else
    $search_date = ""
  end
  if params['year']
    $search_year  = params['year']
  else
    $search_year = ""
  end
  if params['server']
    $search_name  = params['server']
  else
    $search_name = ""
  end
  if params['search']
    $search_param = params['search']
  else
    $search_param = ""
  end
  if params['value']
    $search_value = params['value']
  else
    $search_value = ""
  end
  $host_info  = {}
  $sys_config = {}
  file_array = get_explorer_file_list($search_model,$search_date,$search_year,$search_name,$search_param,$search_value) 
  file_name  = file_array[0]
  $exp_file  = file_name
  layout = $base_dir+"/views/layout.html"
  head   = File.readlines(layout)
  body   = config_report($report_type,$search_name)
  array  = head + body
  array  = array.join("\n")
  "#{array}"
end

# photos

get '/photos' do
  if enable_auth == true
    protect!
  end
  if params['image']
    photo_file = params['image'] 
  else
    redirect '/help'
  end
  if !photo_file.match(/^[A-Z]|[a-z]/) and !photo_file.match(/jpg$|gif$|png$/)
    redirect '/help'
  end
  photo_dir  = $base_dir+"/photos"
  image_file = photo_dir+"/"+photo_file 
  if File.exist?(image_file)
    send_file(image_file)
  else
    redirect '/help'
  end
end

