# Services that should be disabled (based on CIS and other frameworks)

$inetd_services=[
  "time",
  "echo",
  "discard",
  "daytime",
  "chargen",
  "fs",
  "dtspc",
  "exec",
  "comsat",
  "talk",
  "finger",
  "uucp",
  "name",
  "xaudio",
  "netstat",
  "ufsd",
  "rexd",
  "systat",
  "sun-dr",
  "uuidgen",
  "krb5_prop",
  "100068",
  "100146",
  "100147",
  "100150",
  "100221",
  "100232",
  "100235",
  "kerbd",
  "rstatd",
  "rusersd",
  "sprayd",
  "walld",
  "printer",
  "shell",
  "login",
  "telnet",
  "ftp",
  "tftp",
  "100083",
  "100229",
  "100230",
  "100242",
  "100234",
  "100134",
  "100155",
  "rquotad",
  "100424",
  "100422"
]

# Process Security (inetd)

def process_inetd()
  file_name  = "/etc/inetd.conf"
  file_array = exp_file_to_array(file_name)
  if file_array
    puts
    title = "Security Settings ("+file_name+")"
    table = Terminal::Table.new :title => title, :headings => ['Service', 'Current','Recommended','Complies']
    file_array.each do |line|
      if !line.match(/^#/) and line.match(/[A-z]|[0-9]/)
        service       = line.split(/\s+/)[0]
        service_check = $inetd_services.select{|service_check| service_check.match(/^#{service}/)}
        if service_check.to_s.match(/#{service}/)
          curr_val = "Enabled"
          rec_val  = "Disabled"
          comment  = "*No*"
        else
          curr_val = "Enabled"
          rec_val  = "N/A"
          comment  = "N/A"
        end
        row = [service,curr_val,rec_val,comment]
        table.add_row(row)
      end
    end
    puts table
    puts
  end
  return
end
