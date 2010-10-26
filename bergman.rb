require 'rubygems'
require 'fastercsv'

require 'parser'
require 'movie'


def minutes_to_years(m)
  m/60/24/365
end

def days(m)
  m/1440
end

def fictional_today(days)
  DateTime.new(1,1,1) + days
end

File.open("calculation.log", 'w') {|f| f.write("Initiating calculation... \n")}

data_file = "running-times-2010-10-22.list"
initial_time = Time.now
puts "** Processing file #{data_file}..."
f = File.new(data_file)


total_length= 0

movies = []

f.readlines[14..-2].each do|line|
  movies << Parser.parse(line)
end
parsed_time = Time.now

puts "** Data parsed! Initiating calculations..."

ty = Date.today.year.to_s
this_year = movies.select{|m| m.year == ty }
tyfm = this_year.reduce(0){|sum, p| sum + p.length }

ly = (Date.today.year - 1).to_s
last_year = movies.select{|m| m.year == ly }
lyfm = last_year.reduce(0){|sum, p| sum + p.length }
lyrm = DateTime.new(ly.to_i,12,31).yday * 24 * 60

tl = movies.reduce(0){|sum, p| sum + p.length }

final_time = Time.now

tt = final_time-initial_time
tp = parsed_time-initial_time
tc = final_time-parsed_time

puts "** Calculations done! (Total time #{'%.1f' % tt}s. / "+
     "Parsing time #{'%.1f' % tp}s. / "+
     "Calculation time #{'%.1f' % tc}s.)"


puts 
puts "================================================"
puts "=============  REPORT  ========================="
puts "================================================"
puts 
puts "=== #{ly} ======================================"
puts "#{ly} Nº Movies   => #{last_year.size}"
puts "#{ly} Nº Minutes  => #{lyfm} min. (#{'%.2f' % minutes_to_years(lyfm)} years)"
puts "#{ly} speed  => 1 real min. == #{'%.2f' % (lyrm/lyfm)} fictional min"
puts 
puts "=== #{ty} ======================================"
puts "#{ty} Nº Movies   => #{this_year.size}"
puts "#{ty} Nº Minutes  => #{tyfm} min. (#{'%.2f' % minutes_to_years(tyfm)} years)"
puts 
puts "=== TOTAL ======================================"
puts "Total Nº Movies   => #{movies.size}"
puts "Total Nº Minutes  => #{tl} min. (#{'%.2f' % minutes_to_years(tl)} years)"
puts 
ft = fictional_today(days(tl))
puts ft.strftime("Fictional Today => %A %d of %B of %Y at %I:%M%p")