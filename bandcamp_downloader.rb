# encoding: UTF-8
require 'yajl'
require 'open-uri'
require 'trollop'
require 'fileutils'
require 'taglib'

opts = Trollop::options do
	opt :json, "Bandcamp trackinfo json hash file", :type => String, :required => true
end

jf = File.open("#{File.dirname(__FILE__)}/#{opts[:json]}", "r")

if jf.nil?
	puts "Unable to open json file.", "Please make sure the file is in the right location"
	exit
end

j = Yajl::Parser.parse(jf.read.encode('UTF-8', 'IBM862'))
artist = j["artist"]
trackinfo = j["trackinfo"]
album = j["current"]["title"]

puts "Downloading #{artist}'s album: #{album}"

d = "#{File.dirname(__FILE__)}/#{artist} - #{album}"
puts "Download location: \"#{d}\""
FileUtils.mkdir(d)
trackinfo.each {|track|
	puts "downloading #{track["track_num"]}. #{track["title"]}"
	File.open("#{d}/#{track["title"]}.mp3", "wb") {|file|
		file << open(track["file"]).read
	}
	puts "Updating track ID3 tag"
	TagLib::MPEG::File.open("#{d}/#{track["title"]}.mp3") do |file|
		tag = file.tag
	  tag.title= track["title"]
	  tag.artist= artist
	  tag.album= album
	  tag.track= track["track_num"]
		file.save
	end
}

puts "Downloading album art cover:"
File.open("#{d}/#{album}.jpg", "wb") {|file|
	file << open(j["artFullsizeUrl"]).read
}

puts "Finished!"
