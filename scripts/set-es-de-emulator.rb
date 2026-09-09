#!/usr/bin/env ruby

file_path, label = ARGV
abort 'usage: set-es-de-emulator.rb FILE LABEL' unless file_path && label
abort 'invalid emulator label' if label.empty? || label.match?(/[\r\n<>]/)

block = "<alternativeEmulator>\n\t<label>#{label}</label>\n</alternativeEmulator>\n"
content = File.file?(file_path) ? File.read(file_path) : ''

if content.match?(%r{<alternativeEmulator>.*?</alternativeEmulator>}m)
  content.sub!(%r{<alternativeEmulator>.*?</alternativeEmulator>\s*}m, block)
elsif content.empty?
  content = %(<?xml version="1.0"?>\n#{block}<gameList>\n</gameList>\n)
elsif content.start_with?('<?xml')
  declaration, remainder = content.split("\n", 2)
  content = "#{declaration}\n#{block}#{remainder}"
else
  content = "#{block}#{content}"
end

File.write(file_path, content)
