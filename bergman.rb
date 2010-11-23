require 'rubygems'
require 'fastercsv'

require 'parser'
require 'movie'
require 'serialport'

# code to download file
# curl ftp://ftp.fu-berlin.de/pub/misc/movies/database/running-times.list.gz | gzip -d > running-times.list


def datetime_to_time(d)
  usec = (d.sec_fraction * 60 * 60 * 24 * (10**6)).to_i
  Time.gm(d.year,d.month,d.day,d.hour,d.min,d.sec,usec)
end

def minutes_to_years(m)
  m/60/24/365
end

def days(m)
  m/1440
end

def fictional_today(days)
  DateTime.new(1,1,1) + days
end

def file_changed?(crc_line)
  return true unless File.exists?("crc_old.log")
  f = File.new("crc_old.log")
  crc_old =  f.readline
  f.close
  crc_old != crc_line
end

def send_to_serial(year, month, day, hour, minute, speed)
  control = 240

  year_a = year / 100
  year_b = year % 100

  fiction = speed / 100
  res = speed % 100

  puts "** Sending to serial: year=#{year}, month=#{month}, day=#{day}, hour=#{hour}, minute=#{minute}, fiction=#{fiction}, res=#{res}"

  sp = SerialPort.new "/dev/ttyUSB0", 115200
  sp.write([control,year_a,year_b,month,day,hour,minute,fiction,res].pack('ccccccccc'))
  sp.close
end

File.open("calculation.log", 'w') {|f| f.write("Initiating calculation... \n")}

data_file = "running-times.list"
initial_time = Time.now
puts "** Processing file #{data_file}..."

f = File.new(data_file)
crc_line =  f.readline
f.close

if file_changed?(crc_line)
  puts "** File changed"

  from_time = datetime_to_time(DateTime.parse(crc_line.scan(/Date: (.*)/).flatten.first))
  total_length= 0
  movies = []

  f = File.new(data_file)
  f.readlines[14..-2].each do|line|
    movies << Parser.parse(line)
  end

  puts "** Data parsed! Initiating calculations..."
  parsed_time = Time.now

  ty = Date.today.year.to_s
  this_year = movies.select{|m| m.year == ty }
  tyfm = this_year.reduce(0){|sum, p| sum + p.length }
  tyrm = DateTime.new(ty.to_i,12,31).yday * 24 * 60

  ly = (Date.today.year - 1).to_s
  last_year = movies.select{|m| m.year == ly }
  lyfm = last_year.reduce(0){|sum, p| sum + p.length }
  lyrm = DateTime.new(ly.to_i,12,31).yday * 24 * 60

  tl = movies.reduce(0){|sum, p| sum + p.length }

  final_time = Time.now

  tt = final_time  - initial_time
  tp = parsed_time - initial_time
  tc = final_time  - parsed_time

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
  puts "#{ty} speed  => 1 real min. == #{'%.2f' % (tyrm/tyfm)} fictional min"
  puts
  puts "=== TOTAL ======================================"
  puts "Total Nº Movies   => #{movies.size}"
  puts "Total Nº Minutes  => #{tl} min. (#{'%.2f' % minutes_to_years(tl)} years)"
  puts

  speed = ((tyrm/tyfm)*60).to_i
  dd = (Time.now - from_time) * 60 / speed

  ft = fictional_today(days(tl))
  fta = fictional_today(days(tl+(dd/60).to_i))

  puts  ft.strftime("Fictional File  => %A %d of %B of %Y at %I:%M%p")
  puts fta.strftime("Fictional Today => %A %d of %B of %Y at %I:%M%p")

  send_to_serial(fta.year, fta.month, fta.day, fta.hour, fta.min, ((tyrm/tyfm)*6000).to_i)

  File.open("crc_old.log", 'w') {|f| f.write(crc_line)}
else
  puts "** File NOT changed"
end