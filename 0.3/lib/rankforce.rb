# -*- coding: utf-8 -*-
require 'rankforce/crawler'
require 'rankforce/tweet'
require 'rankforce/utils'
require 'rankforce/db'

module RankForce
  VERSION = '0.3.9'
  CRAWLE_URL = "http://2ch-ranking.net/"
  CRAWLE_TIMEOUT = 10
  TABLE_NAME = "thread_lines"
  LOG_LEVEL = 1

  class << self
    # 初期設定
    def init(params)
      begin
        params.merge!(Utils.load(params[:config_path]))
      rescue
        unless Utils.file?(params[:config_path])
          raise "Config file not found."
        end
      ensure
        @log = Log.new(params[:log], params[:debug])
      end
      @tweet = Tweet.new(params[:twitter])
      @short = ShortURL.new({
        :login => params[:bitly][:login],
        :apiKey => params[:bitly][:apiKey]
      })
      migrate(params[:db])
    end

    # DB作成処理
    def migrate(params)
      # database connect
      @db = DB.new(params, TABLE_NAME)
      # schema definition
      @db.create do
        primary_key :id
        string :title
        string :url
        integer :ikioi
        string :board
        string :timeline_url
        timestamp :created_at
        index :url, :unique => true
        index :created_at
      end
    end

    # DB保存処理
    def save_to(data)
      @db.set(data) do |name|
        context = data.map {|k, v| v}.join(",")
        @log.info = "[#{name.upcase}]\s#{context}"
        @log.info.print
      end
    end

    # Twitter送信処理
    def tweet_to(e, board)
      context = "【#{Mapper.to_ja(board)}】#{e[:title]}"
      context+= "(勢い:#{e[:ikioi]}) #{@short.conv(e[:url])}"
      @tweet.post(context) do |url|
        @log.info = "[Twitter]\s#{context}"
        @db.set(e.merge({:timeline_url => url}))
        @log.info.print
      end if @db.timeline_url({:url => e[:url]}).nil?
    end

    # データ取得処理
    def get(params)
      begin
        init(params)
        Crawler.new(params).run do |board, data|
          begin
            save_to data if data[:ikioi] > params[:threshold]
            tweet_to data, board if data[:ikioi] > params[:tweet_threshold]
          rescue SQLite3::BusyException; redo
          rescue => e
            @log.error = e.message
          end
        end
      rescue => e
        @log.error = e.message
      end
      @log.error.dump
    end
  end
end