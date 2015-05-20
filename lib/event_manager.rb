require 'csv'
require 'sunlight/congress'
require 'erb'
require 'time'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/\D/, "")
  if phone_number.length == 11 && phone_number[0] == 0
    return phone_number.strip(0,1)
  elsif phone_number.length == 10
    return phone_number
  else
    return "-"
  end
end

def registration_hour(date)
  time =  Time.strptime(date, '%m/%d/%y %H:%M').strftime("%H:%M")
end

def registration_day(date)
  day =  Time.strptime(date, '%m/%d/%y %H:%M').strftime("%a")
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def best_hour(hours)
  hash = Hash.new(0)
  hours.each do |h|
    hash[h[0...2]] +=1
  end

  puts "3 best registration hours are :"
  hash = hash.sort_by{|k,v| v}.reverse[0..2]
  hash.each do |k,v|
    puts "#{v} hits for #{k}h"
  end
  return
end

def best_day(days)
  hash = Hash.new(0)
  days.each do |h|
    hash[h[0...2]] +=1
  end

  puts "3 best registration days are :"
  hash = hash.sort_by{|k,v| v}.reverse[0..2]
  hash.each do |k,v|
    puts "#{v} hits for #{k}"
  end
  return
end

puts "EventManager initialized"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
template_letter = File.read "form_letter.erb"
erb_letter = ERB.new template_letter
hours = []
days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = clean_phone_number(row[:homephone])
  hour = registration_hour(row[:regdate])
  hours << hour

  day = registration_day(row[:regdate])
  days << day

  #zipcode = clean_zipcode(row[:zipcode])
  #legislators = legislators_by_zipcode(zipcode)
  #form_letter = erb_letter.result(binding)
  #save_thank_you_letters(id, form_letter)
end
puts best_hour(hours)
puts best_day(days)
