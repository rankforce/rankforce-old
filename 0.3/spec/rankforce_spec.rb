# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + "/rankforce_helper"

describe RankForce, 'が実行する処理' do
  before do
    @config_path = "/Users/stay/Config/rankforce3/rspec/rankforce.yml"
    @params = RankForce::Utils.load(@config_path)
    @dbpath = "/Users/stay/Config/rankforce3/rspec/rankforce_test_#{Time.now.to_i}.sqlite"
    @logdir = "/Users/stay/Config/rankforce3/rspec"
    @dummy = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    # DB初期化
    RankForce::DB.new(@params[:db], "thread_lines").delete rescue nil
  end

  describe '基本処理' do
    before do
      @log = RankForce::Rspec::Log.new
      @logger = RankForce::Log.new(@logdir, true)
    end

    describe '正常系' do
      it "コマンドラインから正常に実行出来ること" do
        RankForce.get({:config_path => @config_path})
        @log.get(:error).should be_nil
      end

      it "ログをファイルに書き出せること" do
        msg = Time.now.to_s
        @logger.info = msg
        File.open(@logger.logfile(@logdir)) do |f|
          f.readlines.last.index(msg).should be_true
        end
      end

      it "直近ログを標準出力できること" do
        RankForce.get({:config_path => @config_path})
        # 直近ログは文字列
        @log.print(:info).should be_an_instance_of(String)
      end

      it "すべてのログを標準出力できること" do
        RankForce.get({:config_path => @config_path})
        # すべてのログは配列
        @log.dump(:info).should be_an_instance_of(Array)
      end
    end

    describe '異常系' do
      it "コマンドライン引数で設定ファイルパスを指定しない場合「Config file not found.」エラーになること" do
        RankForce.get({:config_path => nil})
        @log.get(:error).each do |msg|
          msg.should == "Config file not found."
        end
      end

      it "コマンドライン引数で設定ファイルパスが間違っている場合「Config file not found.」エラーになること" do
        RankForce.get({:config_path => @dummy})
        @log.get(:error).each do |msg|
          msg.should == "Config file not found."
        end
      end
    end
  end

  describe 'クローリング処理' do
    describe '正常系' do
      it "勢いがあるスレの情報を取得できること" do
        crawler = RankForce::Crawler.new({
          :threshold => 3000
        })
        (crawler.crawle_from "news").should_not be_empty
      end
    end

    describe '異常系' do
      it "勢いがないスレの情報は取得できないこと" do
        crawler = RankForce::Crawler.new({
          :threshold => 300000
        })
        (crawler.crawle_from "news").should be_empty
      end
    end
  end

  describe 'Twitter処理' do
    before do
      @rspec_tweet = RankForce::Rspec::Tweet.new
      @send_msg = Time.now.to_s
      @send_msg_ja = "てすとだよ～♪#{@send_msg}"
    end

    describe '正常系' do
      it "TwitterにPOSTできること" do
        msg = @rspec_tweet.get_tweeted_msg(@params, @send_msg)
        msg.should == @send_msg
      end

      it "Twitterに日本語のPOSTができること" do
        msg = @rspec_tweet.get_tweeted_msg(@params, @send_msg_ja)
        msg.should == @send_msg_ja
      end
    end

    describe '異常系' do
      it "consumer keyが間違っている場合、TwitterにPOSTできないこと" do
        @params[:twitter][:consumer_key] = @dummy
        msg = @rspec_tweet.get_tweeted_msg(@params)
        msg.should match(/401: Could not authenticate with OAuth./)
      end

      it "consumer secretが間違っている場合、TwitterにPOSTできないこと" do
        @params[:twitter][:consumer_secret] = @dummy
        msg = @rspec_tweet.get_tweeted_msg(@params)
        msg.should match(/401: Could not authenticate with OAuth./)
      end

      it "oauth tokenが間違っている場合、TwitterにPOSTできないこと" do
        @params[:twitter][:oauth_token] = @dummy
        msg = @rspec_tweet.get_tweeted_msg(@params)
        msg.should match(/401: Invalid \/ expired Token/)
      end

      it "oauth token secretが間違っている場合、TwitterにPOSTできないこと" do
        @params[:twitter][:oauth_token_secret] = @dummy
        msg = @rspec_tweet.get_tweeted_msg(@params)
        msg.should match(/401: Could not authenticate with OAuth./)
      end
    end
  end

  describe 'その他' do
    before do
      @board_en = "news"
      @board_ja = "ニュース速報"
      @test_url = "http://www.yahoo.co.jp"
    end

    describe '正常系' do
      it "掲示板名を日本語名から英語名にマッピングできること" do
        RankForce::Mapper.to_ja(@board_en).should == @board_ja
      end

      it "掲示板名を英語名から日本語名にマッピングできること" do
        RankForce::Mapper.to_en(@board_ja).should == @board_en
      end

      it "bit.lyで短縮URLに変換できること" do
        @short = RankForce::ShortURL.new({
          :login => @params[:bitly][:login],
          :apiKey => @params[:bitly][:apiKey]
        })
        @short.conv(@test_url).should match(/http:\/\/bit\.ly\/\w{6}/)
      end

      it "TinyURLで短縮URLに変換できること" do
        @short = RankForce::ShortURL.new({
          :api => "tinyurl"
        })
        @short.conv(@test_url).should match(/http:\/\/tinyurl\.com\/.*/)
      end
    end
  end
end
