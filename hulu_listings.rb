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
#  Removing line

require 'rubygems'
require 'hpricot'
require 'open-uri'

LISTING_LIMIT = 5
DAYS_TO_RUN   = %w( Thu Fri Sat )     # Only run this code on Thu, Fri & Sat
START_TIME    = 19                    # Between 7-9 pm
END_TIME      = 21
SHOWS         = ['Psych', 'Burn Notice', 'Monk', 'Bones']

def retrieve_show_names(title)
  tvshow = title.downcase.strip.split(/\s/).join('-')
  count = 1
  display_text = "-- #{title} --\n"
  doc = Hpricot(open("http://www.hulu.com/#{tvshow}"))

  (doc/"table.vex-episode//td.c1/a").each do |item|
    return display_text if count == LISTING_LIMIT
    display_text << item.inner_html + "\n"
    count = count + 1
  end

  return display_text
end

def time_to_run?
  time = Time.now
  hour = time.hour
  day = time.strftime("%a")
  return false if !DAYS_TO_RUN.include?(day)  

  if hour >= 19 && hour <= 21
    return true
  else
    return false
  end
end

exit if time_to_run? == false

display = ''

SHOWS.each do |show|
  display << retrieve_show_names(show) + "\n\n"
end

print display