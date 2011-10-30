#!/usr/bin/env ruby

# Let's develop the idea of this script:
#
# Clean HTML pages from most stuff and extract text out of it
#
# (C) Copyright 2011, by Daniel Schnell, all rights reserved
#
# from BTE (Body Text Extraction) by Finn

require 'rubygems'
require 'htmlentities'


class HtmlExtractor
        # class variables
        @@html_font_del     = ["b", "big", "i", "s", "small", "strike", "tt", "u"]

        @@html_phrase_del   = ["abbr", "acronym", "cite", "dfn", "em", "kbd",
                               "samp", "strong", "var"]
        @@html_phrase_swipe = ["code", "del"]

        @@html_inline_del   = ["a", "basefont", "bdo", "br", "font", "area",
                               "img", "param", "q", "sub", "sup", "span"]
        @@html_inline_swipe = ["applet", "iframe", "map", "object", "script"]

        @@html_block_del    = ["blockquote", "center", "hr", "ins", "p", "pre"]

        @@html_block_swipe  = ["address", "del", "h1", "h2", "h3", "h4", "h5", "h6",
                               "isindex", "noscript"]

        @@html_table_swipe  = ["table"]

        @@html_list_swipe   = ["dir", "dl", "dt", "dd", "li", "menu", "ol", "ul"]

        @@html_form_del     = ["form"]

        @@to_del = @@html_font_del+@@html_phrase_del+
                   @@html_inline_del+@@html_block_del + @@html_form_del
        @@to_swipe = @@html_table_swipe+
                     @@html_list_swipe+
                     @@html_phrase_swipe +
                     @@html_inline_swipe +
                     @@html_block_swipe
        
    def initialize
        
    end


    def remove_crap!(data)

        # we are not interested in anything up to <body
        data.gsub!(/.*<body/im, "<body")
        # and everything behind it
        data.gsub!(/\/body>.*/im, "/body>")

        if not data.start_with?("<body")
            # no body directive: invalid html document found
            data.clear
            return data
        end
        # remove footer marked by comment
        data.gsub!(/<!-- start: footer -->.*?<!-- end: footer -->/m, "")

        #############################
        # get rid of comments       #
        #############################
        # comments begin with a `<!'
        # followed by 0 or more comments;

        # this is actually to eat up comments in non
        # random places

        # not suppose to have any white space here

        # just a quick start;
        # each comment starts with a `--'
        # and includes all text up to and including
        # the *next* occurrence of `--'
        # and may have trailing white space
        #   (albeit not leading white space XXX)
        # repetire ad libitum  XXX should be * not +
        # trailing non comment text
        # up to a `>'

        # this silliness for embedded comments in tags
        #    if ($1 || $3)   "<!$1 $3>";

        data.gsub!(/<!(.*?)(--.*?--\s*)+(.*?)>/m, "")

        # remove various empirically found texts like disclaimers, footers, etc.

        # remove {...}</span>
        data.gsub!(/\{[^<]*?\}\s*<\/span>/m, "</span>")                                # XXX DS: maybe too impacting !
        # remove {...}</div>
        data.gsub!(/\{[^<]*?\}\s*<\/div>/m, "</div>")                                  # XXX DS: maybe too impacting !
        data.gsub!(/<div class="image.*?<\/div>/m, "")
        data.gsub!(/<div class="footer_disclaimer.*?<\/div>/m, "")
        data.gsub!(/<p class="[^>]*disclaimer.*?<\/p>/m, "")
        data.gsub!(/<p id="[^>]*disclaimer.*?<\/p>/m, "")
        data.gsub!(/<div id="[^>]*disclaimer.*?<\/div>/m, "")
        data.gsub!(/<style.*?<\/style>/m, "")

    end


    def remove_html!(data)
        @@to_del.each { |term|
            term_e1 = "<"+term+"( .*?|)>"   # remove <term ...> or <term>
            term_e2 = "<\/"+term+">"
            #puts term_e1
            #puts term_e2
            rx1 = Regexp.new(term_e1, Regexp::IGNORECASE | Regexp::MULTILINE)
            rx2 = Regexp.new(term_e2, Regexp::IGNORECASE | Regexp::MULTILINE)
            data.gsub!(rx1, " ")
            data.gsub!(rx2, " ")
        }

        @@to_swipe.each { |term|
            term_e1 = "<"+term+"( .*?|)>.*?<\/"+term+">"
            #puts term_e1
            rx1 = Regexp.new(term_e1, Regexp::IGNORECASE | Regexp::MULTILINE)
            data.gsub!(rx1, " ")
        }
    end


    def identify_tags!(data)

        ###############################
        # identify the remaining tags #
        ###############################


        # we brutally add period before unambiguous block elements
        #    $data =~ s/([^\!\_\-\:\;\,\.\?])\s*<(ADDRESS|BLOCKQUOTE|BR|CENTER|DIR|DIV|DL|FIELDSET|FORM|H1|H2|H3|H4|H5|H6|HR|ISINDEX|MENU|NOFRAMES|NOSCRIPT|OL|P|PRE|TABLE|UL|DD|DT|FRAMESET|LI|TBODY|TD|TFOOT|TH|THEAD|TR)( |>)/$1. <$2$3/gis;


        # following expression is greatly simplified and it will probably
        # miss something, but hopefully it will
        # protect us from the segmentation faults caused by original expression

        data.gsub!(/<[^>]+>/m, " XTAGX ");

#    $data =~ s{ <                 # opening angle bracket
#
#		    (?:           # Non-backreffing grouping paren
#		     [^>\'\"] *   # 0 or more things that are neither
#		                  # > nor ' nor "
#		     |            #    or else
#		     \".*?\"      # a section between double quotes
#		                  # (stingy match)
#		     |            #    or else
#		     \'.*?\'      # a section between single quotes
#		                  # (stingy match)
#		     ) +          # repetire ad libitum
#		                  #  hm.... are null tags <> legal? XXX
#		     >            # closing angle bracket
#		 }{ XTAGX }gsx;     # mutate into nada, nothing, and niente

    end



    def clean!(data)
        txt = data
        remove_crap!(txt)
        remove_html!(txt)
        txt = HTMLEntities.new.decode(txt)

        # translate DOS to unix
        txt.gsub!(/\r\n/m, "\n")

        # remove empty lines
        txt.gsub!(/^\s+?$/, "\n")


        # replace newlines and tabs with spaces
        txt.gsub!("\n", " ")
        txt.gsub!("\t", " ")

        # squeeze multiple whitespace
        txt.squeeze!(" ")
        txt.squeeze!("\t")
        identify_tags!(txt)

        # split data by identify tag
        tokens = txt.split("XTAGX")

        out = ""
        # only use sections with a critical word mass
        tokens.each {|tok|
            words = tok.split(/\s/m)
            # XXX DS: only count valid words, no "§$%&/()=? etc.
            out += tok if words.size > 25
        }
        out
    end
    
end


def rsscl_test(file_name)
    data = IO.read(file_name)
    cleaner = HtmlExtractor.new

#out = cleaner.remove_crap!(data)
#out = cleaner.remove_html!(data)

    out = cleaner.clean!(data)
    puts out
end