#!/usr/bin/env ruby -w

#
#  hulu_listings.rb
#
#  Created by Craig Williams on 2009-02-04.
#
#  I use this file in conjunction with GeekTool
#  Geektool is set to update every 1800 seconds (30 min)
#  Even though it is called every 30 min it only executes
#  the code on Thur, Fri & Sat between 7-9 pm.
#  

require 'rubygems'
require 'hpricot'
require 'open-uri'

LISTING_LIMIT = 3
DAYS_TO_RUN   = %w( Mon Tue Wed Thu Fri Sat Sun)     
START_TIME    = 8       
@end_time      = 8

if ARGV.size != 0
  @end_time = ARGV[0].to_i
end

HULU_SHOWS    = [
  'Psych',
  'Burn Notice',
  'Warehouse 13',
  'Heroes',
  'Community',
  'Bones',
  'Eastwick',
  'White Collar',
  'Sanctuary',
  'Eureka',
  'Stargate Universe',
  'V',
  'Fringe'
]

def retrieve_show_names(title)
  tvshow = title.downcase.strip.split(/\s/).join('-')
  count = 1
  display_text = "-- #{title} --\n"
  doc = Hpricot(open("http://www.hulu.com/#{tvshow}"))
  #(doc/"table.vex-episode//td.c1/a").each do |item|
  
  (doc/"//div[@class='vslc'][1]/div[@class='vsl vsl-short']/ul/li/a[@class='info_hover']").each do |item|
    return display_text if count == LISTING_LIMIT
    display_text << item.inner_html + "\n"
    count = count + 1
  end

  return display_text
end

def time_to_run?
  time = Time.now
  @hour = time.hour
  day = time.strftime("%a")
  if !DAYS_TO_RUN.include?(day)  
    puts "'#{day}' is not in your days to run parameter"
    return false 
  end
  
  return @hour >= START_TIME && @hour <= @end_time ? true : false
end

if time_to_run? == false
  puts "'#{@hour}' is not in your hours to run parameter"
  exit
end

time_now = Time.now.strftime("%x at %X")
display = "Last run on: #{time_now}\n\n"

HULU_SHOWS.each do |show|
  display << retrieve_show_names(show) + "\n"
end

print display