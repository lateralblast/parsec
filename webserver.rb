#!/usr/bin/env ruby

# Name:         parsec webserver (Explorer Parser)
# Version:      0.1.1
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
  require 'enumerator'
rescue LoadError
  install_gem("enumerator")
end
begin
  require 'iconv'
rescue LoadError
  install_gem("iconv")
end
begin
  require 'unix_crypt'
rescue LoadError
  install_gem("unix-crypt")
end

# Some webserver defaults

default_bind      = "127.0.0.1"
default_port      = "9494"
default_sessions  = "true"
default_errors    = "false"
enable_ssl        = true
enable_auth       = false
ssl_certificate   = "ssl/cert.crt"
ssl_key           = "ssl/pkey.pem"
$ssl_password     = "123456"


set :port,        default_port
set :bind,        default_bind
set :sessions,    default_sessions
set :dump_errors, default_errors

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
      HTPASSWD_PATH = $htpasswd_file
    
      helpers do
        def protect!
          unless authorized?
            response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
            throw(:halt, [401, "Not authorized\n"])
          end
        end
  
        def authorized?
          @auth ||=  Rack::Auth::Basic::Request.new(request.env)
          passwd = File.open(HTPASSWD_PATH).read.split("\n").map {|credential| credential.split(':')}
          if @auth.provided? && @auth.basic? && @auth.credentials
            user, pass = @auth.credentials
            auth = passwd.assoc(user)
            return false unless auth
            [user, UnixCrypt::MD5.build(auth[1][0..2])] == auth
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

$work_dir      = "/tmp"
$output_format = "serverhtml"
$output_file   = ""
$script_name   = "Parsec"
$verbose       = 0
$base_dir      = Dir.pwd
$do_disks      = 0
$host_info     = {}
$sys_config    = {}
$exp_file_list = []
$masked        = 0
$exp_file      = ""
$exp_dir       = $base_dir+"/explorers"


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
  protect!
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
  head  = File.readlines("./views/layout.html")
  body  = list_explorers(search_model,search_date,search_year,search_name)
  array = head + body
  array = array.join("\n")
  "#{array}"
end

# Do report

get '/report' do
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
  report     = ""
  file_array = get_explorer_file_list(search_model,search_date,search_year,search_name) 
  file_name  = file_array[0]
  $exp_file  = file_name
  head  = File.readlines("./views/layout.html")
  body  = config_report(report,search_name)
  array = head + body
  array = array.join("\n")
  "#{array}"
end

