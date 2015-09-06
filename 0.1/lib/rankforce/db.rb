require 'rankforce'
require 'rubygems'
require 'sequel'

module RankForce
  class DB

    def initialize
      @config = RankForce.load('db')
      @table = @config['tablename'].intern
      dbconnect
    end

    def select
      begin
        return dataset
      rescue => e
        RankForce.error(e)
      end
    end

    def update(data = nil, where = nil)
      begin
        raise ArgumentError if where.nil? || data.nil?
        ds = dataset.filter(where).update(data)
        RankForce.info("[DB][UPDATE] #{data.values.join(',')}")
        return ds
      rescue => e
        RankForce.error(e)
      end
    end

    def insert(data = nil)
      result = false
      begin
        raise ArgumentError if data.nil?
        dataset << data
        RankForce.info("[DB][INSERT] #{data.values.join(',')}")
        result = true
      rescue => e
        RankForce.error(e) unless /Duplicate entry/ =~ e.to_s
      end
      result
    end

    private

    def dataset
      @db[@table]
    end

    def dbconnect
      @db = Sequel.connect(
        "mysql://#{@config['user']}:#{@config['pass']}@#{@config['host']}/#{@config['dbname']}",
        {:encoding => @config['encoding']}
      )
    end

  end
end