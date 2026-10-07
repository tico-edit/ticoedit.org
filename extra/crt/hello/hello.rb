#!/usr/bin/env ruby
# hello.rb: a friendly greeting from tico.

names = ARGV.empty? ? ["world"] : ARGV

names.each do |name|
  puts "Hello, #{name}!"
end
