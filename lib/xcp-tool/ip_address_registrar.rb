require 'date'
require 'fileutils'

class IpAddressRegistrar
  attr_accessor :work_dir, :region, :user

  # git repository
  GITREPOSITORY="**"
  REGIONS = {
    "region1" => {
      'ZONEFILE' => '**',
      'PTRZONEFILE' => '**',
      'PTRIDENTIFIER_START' => 'Xen virtual machines',
      'PTRIDENTIFIER_END' => 'GI reserved for virtual machines',
      'DOMAIN' => '**',
    },
  }

  def initialize(params = {})
    user = params[:user] || ENV['USER']

    @region ||= 'region1'
    @work_dir ||= ("/var/tmp/dir." + ENV['USER'])
    @user = user
  end

  def git_clone
    puts("git clone #{GITREPOSITORY} #{@work_dir}")
    r = system("git clone #{GITREPOSITORY} #{@work_dir}")
    $stderr.puts "git clone failed!!!" unless r
    r
  end

  def git_pull
    puts("git pull from  #{GITREPOSITORY}")
    r = system("\(cd #{@work_dir} && git pull origin master && git pull --rebase\)")
    $stderr.puts "[WARN] git pull failure!!" unless r
    r
  end

  def git_push hostname, add=true
    savedir = Dir.pwd
    Dir.chdir(@work_dir)
    %x(git commit -a -m "added #{hostname}") if add
    %x(git commit -a -m "removed #{hostname}") unless add
    r = system("git push origin master")
    unless r
      $stderr.puts "[ERROR] git push error!!!!"
    end
    Dir.chdir(savedir)
    r
  end

  def zone_file_path
    File.join(@work_dir, REGIONS[@region]['ZONEFILE'])
  end

  def ptr_zone_file_path
    File.join(@work_dir, REGIONS[@region]['PTRZONEFILE'])
  end

  def ptridentifier
    REGIONS[@region]['PTRIDENTIFIER_START']
  end

  def ptridentifier_end
    REGIONS[@region]['PTRIDENTIFIER_END']
  end

  def domain
    REGIONS[@region]['DOMAIN']
  end

  def update_work_dir
    skip_clone = File.exists?(@work_dir) && git_pull
    unless skip_clone
      system("rm -rf #{@work_dir}")
      git_clone
    end
  end

  def get_record hostname, cname=false
    return nil if hostname.empty?
    results = {}
    update_work_dir
    results[:a_record] = File.foreach(zone_file_path).find_all {|line|
      /#{hostname}\s*IN\s*A\s*/ =~line
    }
    results[:ptr_record] = File.foreach(ptr_zone_file_path).find_all {|line|
      /\s*IN\s*PTR\s* #{hostname}./ =~ line
    }
    if cname
      results[:cname_record] = File.foreach(zone_file_path).find_all {|line|
        /#{hostname}\s*IN\s*(CNAME|MX)\s*/ =~line
      }
    end
    results.delete_if { |k, v| v.empty? }
    results
  end

  def check_hostname hostname
   update_work_dir
    if /^[a-zA-Z0-9\-]+$/ !~ hostname
      raise "#{hostname} include invalid charactors."
    end
    File.foreach(zone_file_path) do |line|
      if /^#{hostname}\s/ =~ line
        raise "#{hostname} is already registered."
      end
    end
    STDERR.puts "#{hostname} is valid."
    return true
  end

  def update_a_record hostname
    patterns = [/^#{hostname}\s+IN\s+A\s+/]
    unless hostname_exist? hostname
      message = "record is not found in #{zone_file_path}"
      $stderr.puts message
      @err_message += message + "\n"
      return false
    end
    remove_patterns zone_file_path, patterns
  end

  def update_ptr_record hostname
    patterns = [/\s+IN\s+PTR\s+#{hostname}.\s/]
    unless hostname_exist? hostname, ptr_zone_file_path
      message = "record is not found in #{ptr_zone_file_path}"
      $stderr.puts message
      @err_message += message + "\n"
      return false
    end
    remove_patterns ptr_zone_file_path, patterns
  end

  def update_cname_record hostname
    patterns = [
      /;\s(?:\{{3}|\}{3})\sdev-#{hostname}/,
      /\S+#{hostname}\s+IN\s+(?:CNAME|MX\s+10)\s+#{hostname}./,
    ]
    unless hostname_exist? hostname
      message = "record is not found in #{zone_file_path}"
      $stderr.puts message
      @err_message += message + "\n"
      return false
    end
    remove_patterns zone_file_path, patterns
  end

  def remove_record hostname, remove_cname=false
    @err_message = ''
    update_work_dir
    result_a = update_a_record hostname
    result_ptr = update_ptr_record hostname
    result_cname = update_cname_record hostname if remove_cname
    if result_a or result_ptr or result_cname
      git_push hostname, false
    else
      raise @err_message
    end
  end

  def auto_ip_register hostname
    return false unless check_hostname(hostname)
    # Get a reserverd ip address automatically
    prefix = nil
    suffix = 1
    assigned = false
    ipaddr = ''
    update_work_dir
    outfile = File.new(zone_file_path + ".tmp", 'w')

    File.foreach(zone_file_path) do |line|
      if (rewrite_serialno(line, outfile))
        next
      end
      if (not assigned)
        if /\; \{\{\{ Xen virtual machines \(([^\/]+)\// =~ line
        # address pool is found.
          prefix = $1.split('.')[0..2].join('.')
          suffix = 1

        elsif /\; reserved for virtual machines/ =~ line
          # It's ok if address is 10.0.x.{1..254}
          if suffix <= 254
            ipaddr = "#{prefix}.#{suffix}"
            outfile.print "#{hostname}       IN   A   #{ipaddr} ; #{@user}\n"
            assigned = true
          else
            # address pool is full. Go to next pool.
            prefix = nil
            suffix = 1
          end

        elsif prefix != nil
          if /CNAME/ =~ line
            # do nothing
          elsif /^\S+\s+IN\s+A\s+#{prefix}\.#{suffix}/ =~ line
            # address is already registered.
            suffix += 1
          else
            ipaddr = "#{prefix}.#{suffix}"
            outfile.print "#{hostname}       IN   A   #{ipaddr} ; #{@user}\n"
            assigned = true
          end
        end
      end
      outfile.print(line)
    end
    outfile.close
    if ipaddr.empty?
      FileUtils.rm("#{zone_file_path}.tmp")
      raise "registering ipaddr is failed!!" 
    end
    FileUtils.mv("#{zone_file_path}.tmp", "#{zone_file_path}", {:force => true})
    auto_ptr_register ipaddr,hostname
    git_push(hostname)
    return ipaddr
  end

  def auto_ptr_register ip, hostname
    # Get a reserverd ip address automatically
    ptr = ip.split('.').reverse[0..2].join('.')
    prefix = ptr.split('.')[0].to_i
    in_block = false
    assigned = false
    outfile = File.new(ptr_zone_file_path + ".tmp", 'w')

    File.foreach(ptr_zone_file_path) do |line|
      if (rewrite_serialno(line, outfile, false))
        next
      end
      if (not assigned)
        if /\; \{\{\{ #{ptridentifier} \(([^\/]+)\// =~ line
          # address pool is found.
          pre = $1.split('.')[2].to_i
          in_block = (pre == prefix)
        elsif /\; #{ptridentifier_end}/ =~ line
          outfile.print "#{ptr}   IN   PTR   #{hostname}.#{domain}. ; #{@user}\n"
          assigned = true
        elsif in_block
          if /^(\S+)\s+IN\s+PTR\s+/ =~ line
            pre = $1.split('.')[0].to_i
            if (pre >= prefix)
              puts pre
              outfile.print "#{ptr}   IN   PTR   #{hostname}.#{domain}. ; #{@user}\n"
              assigned = true
            end
          end
        end
      end
      outfile.print(line)
    end
    outfile.close
    FileUtils.mv("#{ptr_zone_file_path}.tmp", "#{ptr_zone_file_path}", {:force => true})
  end

  def rewrite_serialno line, outfile, is_zonefile=true
    # Rewrite serial number
    if (/\s+(\d{8})(\d{2}) \; Serial/ =~ line)
      date = $1
      id = $2
      today = Date.today.strftime("%Y%m%d")
      if (date == today)
          newid = "%02d" % (id.to_i + 1)
      else
          newid = "01"
      end
      if is_zonefile
          outfile.puts("                                #{today}#{newid} ; Serial")
      else
          outfile.puts("             #{today}#{newid} ; Serial")
      end
      true
    else
      false
    end
  end

  def hostname_exist? hostname, path=zone_file_path
    return false if hostname.empty?
    system("cat #{path} | grep -E '#{hostname}\s*IN\s*(A|CNAME|MX)\s*' > /dev/null ") or system("cat #{path} | grep -E '\s*IN\s*PTR\s*#{hostname}.' > /dev/null ")
  end

  private
  def remove_patterns path, patterns
    is_zone_file = (path == zone_file_path ? true : false)
    File.open(path + ".tmp", 'w') do |outfile|
      File.foreach(path) do |line|
        next if rewrite_serialno(line, outfile, is_zone_file)
        next if patterns.any? {|p| p =~ line}
        outfile.print(line)
      end
    end
    FileUtils.mv("#{path}.tmp", "#{path}", {:force => true})
  end
end
