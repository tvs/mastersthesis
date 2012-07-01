#!/usr/bin/env ruby

first = true
sum = 0
request_num = 1
File.read(ARGV[0]).each_line do |line|
  if first
    first = false
    next
  end

  fname, response, size, dur, stime, etime = line.split(',')

  val = (201 - response.to_i).abs
  sum += val

  puts "#{sum.fdiv(request_num)}"


  request_num += 1
end

