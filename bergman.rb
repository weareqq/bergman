require 'rubygems'
require 'fastercsv'


#FasterCSV.foreach("running-times.list", :col_sep => "\t") do |row|
# FasterCSV.foreach("mini.list", :col_sep => "\t") do |row|
#   puts row
# end
# 

f = File.new("running-times.list")
total_length= 0
total_movies= 0

f.readlines[14..-2].each do|movie|
  line = movie.split("\t")
  fs = line.delete_if{|f| f == ""}
  
  length = fs[1].strip[/(?:.*:)?(.*)/, 1] 
  #puts " #{fs[0].ljust(95)} ===========>     #{length.rjust(5)} min." if length.to_i == 0 || length.to_i > 300
  
  total_movies += 1
  total_length += length.to_f
end
puts "movies  => #{total_movies}"
puts "counter => #{total_length} min. (#{'%.2f' % (total_length/60/24/365)} years)"
