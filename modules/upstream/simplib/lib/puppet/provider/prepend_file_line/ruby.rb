Puppet::Type.type(:prepend_file_line).provide(:ruby) do
  desc <<-EOM
    Prepend a line to a file.
  EOM

  def exists?
    File.readlines(resource[:path]).find do |line|
      line.chomp == resource[:line].chomp
    end
  end

  def create
    tmpfile = "#{File.dirname(resource[:path])}/.~puppet_#{File.basename(resource[:path])}"
    begin
      File.exist?(tmpfile) and File.unlink(tmpfile)
      tmp_fh = File.open(tmpfile,'w')

      tmp_fh.puts(resource[:line])
      orig_fh = File.open(resource[:path],'r')
      orig_fh.each_line do |ln|
        tmp_fh.puts(ln)
      end
      orig_fh.close
      tmp_fh.close

      FileUtils.mv(tmpfile,resource[:path])
    rescue
      fail(Puppet::Error,"Error when prepending line to #{resource[:path]}")
    end
  end
end
