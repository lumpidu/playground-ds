#!/usr/bin/env ruby
# encoding: utf-8

$: << Dir.pwd
require 'rubygems'
require 'english'
require 'iconv'

def lev_distance(str1, str2)
    # if $KCODE =~ /^U/i
      unpack_rule = 'U*'
    # else
    #   unpack_rule = 'C*'
    # end
    s = str1.unpack(unpack_rule)
    t = str2.unpack(unpack_rule)
    n = s.length
    m = t.length
    return m if (0 == n)
    return n if (0 == m)

    d = (0..m).to_a
    x = nil

    (0...n).each do |i|
      e = i+1
      (0...m).each do |j|
        cost = (s[i] == t[j]) ? 0 : 1
        x = [
          d[j+1] + 1, # insertion
          e + 1,      # deletion
          d[j] + cost # substitution
        ].min
        d[j] = e
        e = x
      end
      d[m] = x
    end

    return x
end

corpus = File.read(ARGV[0], :encoding => "UTF-8")
corpus_cleaned = Iconv.conv("UTF-8//IGNORE", "ISO-8859-1", corpus)
# whole corpus as array

cA = corpus_cleaned.split("\n").keep_if { |x| not x.start_with?(" ====================== >>>>") }

sim = [[0, 0], [0,0]]

for ii in 0..cA.count do
#for ii in 0..0
    #puts cA.at(ii)
    for jj in ii+1..cA.count do
    #for jj in ii+1..50
        next if nil == cA.at(ii) or nil == cA.at(jj)
        dist = lev_distance(cA.at(ii), cA.at(jj))

        # break if at least 10 succeeding elements visited and distance too high
        break if ((dist > (cA.at(ii).size * 0.75)) and (jj > ii + 10))
        sim[ii,jj] = dist
        puts "[" + ii.to_s + ", " + jj.to_s + "]" + " => " + sim[ii,jj].to_s if dist < (cA.at(ii).size)
    end
end


