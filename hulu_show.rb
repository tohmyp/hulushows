#!/usr/bin/env ruby -w

require "rubygems"
require "nokogiri"
require "open-uri"

module Hulu
  class Show
    attr_accessor :name, :show_title, :season, :episode, :running_time

    @@shows = []
    @@subscribed_shows = [
      'Psych',
      'Burn Notice',
      'Warehouse 13',
      'Community',
      'Bones',
      'White Collar',
      'Sanctuary',
      'Fringe',
      'Rookie Blue',
      'Castle',
      'Traffic Light',
      'In Plain Sight'
    ]

    def initialize
      yield self if block_given?
    end

    def video_info(info)
      @season, @episode, @running_time = info.scan(/Season\s+(\d+)\s+\:\s+Ep\.?\s+(\d+)\S+\(([0-9:]+)\)/i).first
    end

    def title_info(info)
      @name, @show_title = info.scan(/(.*)\:\s?(.*)/).first
    end

    #==============================================================
    # Class methods
    #==============================================================

    def self.list_subscribed_shows
      @@shows.each do |show|
        puts "\n\n=================="
        puts "Name: #{show.name}"
        puts "Show title: #{show.show_title}"
        puts "Season: #{show.season} Ep. #{show.episode}"
        puts "Running time: #{show.running_time}"
      end
    end

    def self.add_show(show)
      @@shows << show
    end

    def self.shows
      @@shows
    end

    def self.add_subscribed_shows(*shows)      
      shows.each do |show|
        @@subscribed_shows << show unless @@subscribed_shows.include?(show)
      end
    end

    def self.subscribed_shows
      @@subscribed_shows
    end
  end
end


#==============================================================
# Execution
#==============================================================
Hulu::Show.add_subscribed_shows('Love Bites', 'Misfits')

(1..20).each do |page_number|

  url = "http://www.hulu.com/recent/episodes?h=21&page=#{page_number}"
  doc = Nokogiri::HTML(open(url))

  doc.css(".home-thumb").each do |show_info_container|
    hulu_show = Hulu::Show.new do |show|
      show.title_info(show_info_container.css('.show-title-gray').text)
      show.video_info(show_info_container.css('.video-info').first.text)
    end

    if Hulu::Show.subscribed_shows.include?(hulu_show.name)
      Hulu::Show.add_show(hulu_show)
    end
  end

end

puts "\n\nShow count: #{Hulu::Show.shows.count}"
Hulu::Show.list_subscribed_shows
