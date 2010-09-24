require 'rubygems'
require 'fastercsv'

require 'parser'
require 'movie'

#FasterCSV.foreach("running-times.list", :col_sep => "\t") do |row|
# FasterCSV.foreach("mini.list", :col_sep => "\t") do |row|
#   puts row
# end
# 

def minutes_to_years(m)
  m/60/24/365
end


File.open("calculation.log", 'w') {|f| f.write("Initiating calculation... \n")}

f = File.new("running-times-2010-09-02.list")


total_length= 0

movies = []

f.readlines[14..-2].each do|line|
  movies << Parser.parse(line)
end

tl = movies.reduce(0){|sum, p| sum + p.length }

puts "movies  => #{movies.size}"
puts "counter => #{tl} min. (#{'%.2f' % minutes_to_years(tl)} years)"

