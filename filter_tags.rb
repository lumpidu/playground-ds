# -*- encoding : utf-8 -*-
#!/usr/bin/env ruby 

require 'getoptlong'
require 'fileutils'


# parse cmd line
if ( nil == ARGV[0] ) then
    puts "No file name given !"
    exit (1)
end


opts = GetoptLong.new(
    [ "--file", "-f",   GetoptLong::REQUIRED_ARGUMENT ],
    [ "--start","-s",   GetoptLong::REQUIRED_ARGUMENT ],
    [ "--end",  "-e",   GetoptLong::REQUIRED_ARGUMENT ],
    [ "--help", "-h",   GetoptLong::NO_ARGUMENT ]
)

file=String.new
startpattern=String.new
endpattern=String.new

begin
    opts.each do |opt, arg|
        case opt
            when "--file"
                file=arg
                 
            when "--start"
                startpattern=arg
                 
            when "--end"
                endpattern=arg
                 
            when "--help"
                exit 0
        end
    end

rescue => oops
    puts "wrong option given: #{oops.to_s}"
end

# test file
if (! File.exist?(file)) then
    puts "File #{file} doesn't exist !"
    exit (1)
end

# read in file and match all patterns from startpattern to endpattern
File.open(file, "rb")  do | in_file|
    content_s = String.new
    in_file.read(File.size(file), content_s)
    starts = Regexp.escape(startpattern)
    ends = Regexp.escape(endpattern)
    regex = starts+".*?"+ends
    puts regex
    r1 = Regexp.new(regex, Regexp::MULTILINE)
    #r1 = Regexp.new(starts)
    content_s =~ r1
    puts $~
end
