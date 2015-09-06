# -*- coding: utf-8 -*-
require 'parallel_runner'
require 'mechanize'

module RankForce
  class Crawler
    def initialize(params)
      valiable_set(params)
    end

    def valiable_set(params)
      params.each do |k, v|
        self.instance_variable_set("@#{k.to_s}", v)
      end
    end

    def crawle_from(board)
      list = []
      agent = Mechanize.new
      agent.read_timeout = CRAWLE_TIMEOUT
      site = agent.get("#{CRAWLE_URL}?board=#{board}")
      lines = (site/'//table[@class="forces"]/tr')
      lines.each do |line|
        ikioi = line.search("td.ikioi").text.to_i
        url = (line.search("td.title a").map do |e|
          CRAWLE_URL + e["href"].to_s
        end)[0]
        next if url.nil? || ikioi < @threshold
        title = line.search("td.title").text
        date = Time.at($1.to_i).to_s if /(\d{10})/ =~ url
        list << {
          :ikioi => ikioi,
          :title => title,
          :url => url,
          :board => board,
          :created_at => date
        }
      end
      list
    end

    def run
      Runner.parallel(@boards) do |board|
        (crawle_from board).each do |res|
          yield board, res
        end
      end
    end
  end
end