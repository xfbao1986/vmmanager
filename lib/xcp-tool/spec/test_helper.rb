def set_path(testfile)
  self_file =
    if File.symlink?(testfile)
      require 'pathname'
      Pathname.new(testfile).realpath
    else
      testfile
    end
  $:.unshift(File.dirname(self_file) + '/../')
  $:.unshift(File.dirname(self_file) + '/')
end

def capture(stream)
  begin
    stream = stream.to_s
    eval "$#{stream} = StringIO.new"
    yield
    result = eval("$#{stream}").string
  ensure
    eval("$#{stream} = #{stream.upcase}")
  end
  result
end

def spec_root_path
  File.dirname(File.expand_path(__FILE__))
end
