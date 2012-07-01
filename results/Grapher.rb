#!/usr/bin/env ruby

require 'optparse'

OPTIONS = {
  :type => :byte,
  :output => $stdout,
  :file => 'mout.txt',
  :multiplier => 1
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: change_file_size [options]"

  opts.on("-f", "--file [FILE]", "Surge file to edit", "  Default: #{OPTIONS[:file]}") do |v|
    OPTIONS[:file] = v
  end

  opts.on("-o", "--output [FILE]", "Output file (mapping)", "  Default: STDOUT") do |f|
    OPTIONS[:output] = File.open(f, "w")
  end

  opts.on("-m", "--multiplier [NUM]", Integer, "Multiplier to increase file size by",
          "  Default: #{OPTIONS[:multiplier]}") do |m|
    OPTIONS[:multiplier] = m
  end
end
parser.parse!

class SurgeFile
  attr_reader :hits, :size, :group

  def initialize(hits, size, group)
    @hits = hits
    @size = size
    @group = group
  end
end

files = []
File.read(OPTIONS[:file]).each_line do |line|
  hits,size,group = line.split

  hits = hits.to_i
  size = size.to_i * OPTIONS[:multiplier]
  size = case OPTIONS[:type]
       when :byte then size
       when :kilobyte then size * 1_024
       when :megabyte then size * 1_048_576
       when :gigabyte then size * 1_073_741_824
       end
  group = group.to_i

  file = SurgeFile.new(hits, size, group)

  files << file
end
files.sort_by { |f| f.size }

def get_size_from_string(size)
  case size
  when /\d+B$/i  then size.to_i
  when /\d+KB$/i then size.to_i * 1_024
  when /\d+MB$/i then size.to_i * 1_048_576
  when /\d+GB$/i then size.to_i * 1_073_741_824
  end
end

total_files = files.size
total_requests = files.inject(0) { |sum, f| sum + f.hits }

puts "Label,Size (bytes),CDF,PDF-existence,PDF-requests"
sizes = ["1B", "1KB", "5KB", "50KB", "1MB", "10MB", "100MB"]
sizes.enum_for(:each_cons, 2).map do |size_l, size_r|
  left_size = get_size_from_string(size_l)
  right_size = get_size_from_string(size_r)


  # PDF
  files_between = files.select { |f| left_size <= f.size and f.size < right_size }
  total_hits = files_between.inject(0) { |sum, f| sum + f.hits }
  total_num_between = files_between.size

  # CDF
  files_under = files.select { |f| f.size < right_size }
  total_num = files_under.size

  OPTIONS[:output].puts "#{size_l},#{left_size},#{total_num.fdiv(total_files)},#{total_num_between.fdiv(total_files)},#{total_hits.fdiv(total_requests)}"
end
