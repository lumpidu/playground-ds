class ArcFileParser
    # Parses Directory with Arc Files
    #
    # Copyright (C) Daniel Schnell. All rights reserved.

    # @param    dir_name    Arc File name
    def initialize(dir_name)
        # examine given directory
        if not Dir.exist?(dir_name)
            raise "File not found"
        end

        @dir = Dir.new(dir_name)
        @files = Array.new
        @dir.each { |filename|
            @files << dir_name + '/'+ filename  if filename.end_with?("arc.gz")
        }
        throw "No Arc files (*.arc.gz) found in #{dir_name}" if @files.empty?

    end

    # read offsets of all URLs in Arc File
    # Start_Offset Raw-Size Size URL
    def read_metadata_from_file(file, mime_type)
        # read meta data of all file contents
        return nil if nil == @files.index(file)

        file_contents = String.new
        if not mime_type.empty?
            file_contents = `./arcdump -r -m #{mime_type} #{file}`
        else
            file_contents = `./arcdump -r #{file}`
        end
    end

    # return all filenames of arc files in directory in @dir_name
    def files
        @files
    end

end