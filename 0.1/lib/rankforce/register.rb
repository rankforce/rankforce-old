require 'rankforce'
require 'rankforce/db'
require 'rubygems'
require 'active_support'
require 'hpricot'
require 'open-uri'
require 'timeout'
require 'kconv'
require 'pathname'
require 'twitter'
require 'pp'

module RankForce
  class Scraper
    URL = 'http://ranking.sitepedia.jp/'
    TINY_URL = 'http://tinyurl.com/api-create.php?url='
    TIMEOUT = 10

    def initialize(init)
      @threshold = init[:threshold]
      @board = init[:board]
      @url = "#{URL}?board=#{@board}"
    end

    def exec
      res = nil
      begin
        html = timeout(TIMEOUT) do Hpricot(open(@url).read) end
        res = (html.search("//table[@class='forces']/tr")).each_with_object [] do |e, r|
          ikioi      = e.search("[@class='ikioi']").inner_text
          title      = e.search("[@class='title']").inner_text.toutf8
          cache_url  = e.search("[@class='title']/a").to_s.scan(/(cache.+?)\"/).to_s
          origin_url = e.search("[@class='title']/a").to_s.scan(/http?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:\@&=+\$,%#]+/)[0]
          url        = origin_url || cache_url

          next if title.empty? || ikioi.empty? || url.nil?
          url = short_url(URL + url)

          boards = e.search("[@class='board']").inner_text.toutf8, html.search("//h2[@class='boardTitle']").inner_text.toutf8
          board  = boards[0].empty? ? boards[1] : boards[0]
          thread_date = Time.at((url.split(/\//)[6] || cache_url.scan(/(\d{10})/).to_s).to_i)

          r << {:url => url,
            :ikioi => ikioi,
            :title => title.chop,
            :board => board,
            :board_id => @board,
            :thread_date => thread_date,
            :register_date => Time.now
          } if ikioi.to_i > @threshold
        end
      rescue Timeout::Error => e
        RankForce.error(e.message)
      rescue => e
        RankForce.error(e.message)
      end
      res
    end

    def short_url(long_url)
      begin
        (timeout(TIMEOUT) do Hpricot(open(TINY_URL + long_url).read) end).to_s
      rescue Timeout::Error => e
        RankForce.error(e.message)
        long_url
      rescue => e
        RankForce.error(e.message)
        long_url
      end
    end
  end

  class Tweet
    TWITTER_URL = 'http://twitter.com'
    TWEET_URL = "#{TWITTER_URL}/statuses/update.json"

    def initialize
      prepare_oauth_access
    end

    def prepare_oauth_access
      @oauth = Twitter::OAuth.new(
        RankForce.load_twitter('consumer_key'),
        RankForce.load_twitter('consumer_secret')
      )
      @oauth.authorize_from_access(
        RankForce.load_twitter('access_token'),
        RankForce.load_twitter('access_token_secret')
      )
    end

    def post(message = nil)
      result = false
      begin
        status = Twitter::Base.new(@oauth).update(message)
        RankForce.info("[Twitter]#{status.text}")
        result = true
      rescue => e
        RankForce.error(e.message)
      end
      result
    end
  end

  class Register < RankForce::DB
    def initialize
      super
    end

    # スレが登録されていない場合はInsertする
    # スレが登録されている場合は、勢いがを確認し、勢いが高い場合にUpdateする
    def custom_insert(data = nil)
      begin
        unless insert(data)
          ds = select.filter({:title => data[:title]})
          ds.each do |e|
            if data[:ikioi].to_i > e[:ikioi].to_i
             update({:ikioi => data[:ikioi], :title => data[:title]}, {:id => e[:id]})
            end
          end
          false
        else
          true
        end
      rescue => e
        RankForce.error(e.message)
        false
      end
    end
  end

  module Output
    class DB < RankForce::DB
      def initialize
        super
      end

      def custom_select(where, grep)
        begin
          ds = select.grep(:thread_date, "#{grep}%").order(:thread_date)
          ds = ds.filter({:board_id => where}) unless where.nil?
          return ds
        rescue => e
          RankForce.error(e.message)
        end
      end
    end

    class Format
      def initialize(path, board_id)
        @board_id = board_id
        db = RankForce::Output::DB.new
        @data = db.custom_select(@board_id, Time.now.strftime("%Y-%m-%d"))
        @path = path
      end

      def output(data, filepath)
        save = false
        if File.exist?(@path)
          filepath = Pathname.new(filepath).cleanpath
          begin
            File.open(filepath, 'w') do |file|
              file.write(data)
            end
            save = true
          rescue => e
            RankForce.error(e.message)
          end
        end
        save
      end
    end

    class CSV < RankForce::Output::Format
      def initialize(path, board_id)
        super
      end

      def generate
        row = @data.each_with_object [] do |e, r|
          r << "\"#{e[:board]}\",\"#{e[:ikioi]}\",\"#{e[:title]}\",\"#{e[:url]}\""
        end
        output(row.join("\n"))
      end

      private

      def output(data)
        filepath = "#{@path}/rankforce_csv_#{@board_id}_#{Time.now.strftime("%Y%m%d")}.csv"
        result = super(data, filepath)
        RankForce.info("[CSV] #{filepath}") if result
      end
    end

    class XML < RankForce::Output::Format
      def initialize(path, board_id)
        super
        # [square, round, square_outlined, round_outlined, square_outline,
        #  round_outline, square_outline, round_outline]
        @graph_bullet = 'round_outlined'
        @@gid = 1
      end

      def generate
        series_data, graph_data = [], {:board => nil, :thread_data => []}
        @data.each do |e|
          series_data << e[:thread_date].strftime("%H:%M")
          graph_data[:board] ||= e[:board]
          graph_data[:thread_data] << {:ikioi => e[:ikioi], :url => e[:url], :title => RankForce.escape(e[:title])}
        end
        xml  = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<chart>\n"
        xml += series(series_data)
        xml += graph(graph_data)
        xml += "</chart>"
        output(xml)
      end

      private

      def output(data)
        filepath = "#{@path}/rankforce_xml_#{@board_id}_#{Time.now.strftime("%Y%m%d")}.xml"
        result = super(data, filepath)
        RankForce.info("[XML] #{filepath}") if result
      end

      def series(data)
        value = "\t\t<value xid=\"0\"></value>\n"
        xml = "\t<series>\n"
        data.each_with_index do |e, i|
          value = "" if i == 0
          value += "\t\t<value xid=\"#{i}\">#{e}</value>\n"
        end
        xml += value
        xml += "\t</series>\n"
      end

      def graph(data)
        value = "\t\t\t<value xid=\"0\"></value>\n"
        xml = "\t<graphs>\n"
        xml += "\t\t<graph gid=\"#{@@gid}\" title=\"#{data[:board]}\">\n"
        @@gid += 1
        data[:thread_data].each_with_index do |e, i|
          value = "" if i == 0
          xml += "\t\t\t<value xid=\"#{i}\" bullet=\"#{@graph_bullet}\" url=\"#{e[:url]}\" description=\"#{e[:title]}\">#{e[:ikioi]}</value>\n"
        end
        xml += value
        xml += "\t\t</graph>\n"
        xml += "\t</graphs>\n"
      end
    end
  end
end