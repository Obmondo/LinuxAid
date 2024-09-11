#!/usr/bin/env ruby
#
# Crude validation of ERB-rendered kickstart files
require 'erb'
require 'ostruct'
require 'tempfile'


class Node < OpenStruct
  def render(f)
    ERB.new(File.read(f)).result(binding)
  end

  def self.metadata
    Node
  end

  def self.[] arg
    Node
  end

end

def file_url url
    "https://base/url/#{url}"
end

def stage_done_url url
    "https://base/url/#{url}"
end

et = Node.new({:node => Node, :repo_url => 'https://repo/url',})

ks = et.render(ARGV[0])
ksf = Tempfile.new('ad')
p = ksf.path
ksf.write(ks)
ksf.flush

out = %x{ksvalidator #{p}}

ksf.close
ksf.unlink

exit if $?.exitstatus.zero? and out.length.zero?

STDERR.puts out
exit 1
