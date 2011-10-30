#!/usr/bin/env ruby
#
# Arc File Text Extractor
#
# Copyright (C) Daniel Schnell. All rights reserved.


$: << Dir.pwd
require 'iconv'
require 'arc_file_parser'
require 'getoptlong'
require 'zlib'
require 'stringio'
require 'RssNewsParser'

opts = GetoptLong.new(
    [ "--dir",      "-d", GetoptLong::REQUIRED_ARGUMENT ],
    [ "--file",     "-f", GetoptLong::REQUIRED_ARGUMENT ],
    [ "--whitelist","-w", GetoptLong::REQUIRED_ARGUMENT ],
    [ "--mime",     "-m", GetoptLong::REQUIRED_ARGUMENT ],
    [ "--help",     "-h", GetoptLong::NO_ARGUMENT ]
)

dir_string  = String.new
file_string = String.new
mime_string = String.new
whitelist_string = String.new

begin
    opts.each do |opt, arg|
        case opt
            when "--dir"
                dir_string=arg

            when "--file"
                file_string=arg

            when "--mime"
                 mime_string=arg

            when "--whitelist"
                whitelist_string=arg

            when "--help"
                # print Synopsis
                puts "Synopsis missing"
                exit 0
        end
    end
rescue => oops
    puts "wrong option given: #{oops.to_s}"
end


if dir_string.empty?
    puts "Missing argument: --dir <directory with arc files>"
    exit -1
end

@output = File.new(file_string, "w") if not file_string.empty?
@whitelist = whitelist_string.split if not whitelist_string.empty?

parser = RssNewsParser.new

begin
    afp = ArcFileParser.new(dir_string)
    files = afp.files
    puts "Using File          : #{file_string}" if not file_string.empty?
    puts "Using URL White list: #{whitelist_string}" if not whitelist_string.empty?
    files.each do |file|
        puts "read meta data from #{file} ..."

        metadata = afp.read_metadata_from_file(file, mime_string)
        next if metadata.empty?
        fd = File.new(file)

        metadata.each_line do |line|
            next if line.start_with?("#")
            frags = line.split

            # only URLs matching white list

            if not whitelist_string.empty?
                matched = false
                @whitelist.each { |white_url|
                    matched = true if frags[3].match(white_url)
                }
                next if not matched
            end
            # frags[0] Offset
            # frags[1] raw size
            # frags[2] size
            # frags[3] URL

            fd.seek(frags[0].to_i, IO::SEEK_SET)

            # make io object out of string (without gzip footer)
            gzbuf = fd.read(frags[1].to_i)
            f = File.new("html.gz", "w")

            f.write(gzbuf)
            buf = `gunzip <html.gz 2>/dev/null`         # slow, but works

            # The beneath approach doesn't quite work, because
            # the GzipReader class needs a gzip footer which is
            # not contained in a simple gzipped fragment. This is unfortunate
            # as this approach would be cleaner and much faster than the above chosen one
                #sio = StringIO.new(gzbuf)
                #gz = Zlib::GzipReader.new(sio)
                #buf = gz.read(frags[2].to_i)

            # convert to UTF8
            # XXX DS: there are strange characters still in the output: maybe real source encoding detection necessary
            buf_cleaned = Iconv.conv("UTF-8//IGNORE", "ISO-8859-1", buf)

            # parse it
            matcher = parser.parse(buf_cleaned)

            if not matcher.article.empty?
                divider = "====================== >>>> #{frags[3]} | #{frags[0]} | #{frags[1]} | <<<< ==================="
                if file_string.empty?
                    puts divider
                    puts matcher.article
                else
                    @output.write(divider +"\n")
                    @output.write(matcher.article + "\n")
                end

                if frags[0] == "22035827"
                    f = File.new("rec.html", "w")
                    f.write(buf)
                    f.close
                end
            end
        end
    end

    @output.close if not file_string.empty?

rescue => oops
    puts "Something went wrong: #{oops.to_s}"
    exit 1
end



