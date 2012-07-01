#!/usr/bin/env ruby

bname = File.basename(ARGV[0], ".log")

size_out = File.open(bname + "-sizes.csv", 'w')
nums_out = File.open(bname + "-nums.csv", 'w')
hits_out = File.open(bname + "-hits.csv", 'w')

num_cloud = 0
num_disk = 0
num_mem = 0
File.read(ARGV[0]).each_line do |line|
  if line =~ /Sizes: \[(\d+, \d+, \d+)\]/
    size_out.puts $1
  elsif line =~ /Nums: \[(\d+, \d+, \d+)\]/
    nums_out.puts $1
  elsif line =~ /Search (\d+): found in (.+)/
    case $2
    when "memory"
      num_mem += 1
    when "disk"
      num_disk += 1
    when "cloud"
      num_cloud += 1
    end
    hits_out.puts "#{num_mem},#{num_disk},#{num_cloud}"
  elsif line =~ /Search (\d+): not found/
    hits_out.puts "#{num_mem},#{num_disk},#{num_cloud}"
  end
end

size_out.close
nums_out.close
hits_out.close
