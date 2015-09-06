require 'yaml'
require 'cgi'

module RankForce
  VERSION = '0.0.3'

  class << self
    def config=(path)
      @@config = YAML.load_file(path)
    end

    def load(*args)
      elem = Marshal.load(Marshal.dump(@@config))
      args.each do |key|
        elem = elem[key]
      end
      elem
    end

    def load_twitter(key)
      load("twitter", key)
    end

    def load_db(key)
      load("db", key)
    end

    def escape(e)
      CGI.escapeHTML(e.gsub(/\"/, '\''))
    end

    def error(e)
      logger(e, 'error') unless e.nil?
    end

    def info(e)
      logger(e, 'info') unless e.nil?
    end

    private

    def logger(msg, level)
      require 'rankforce/log'
      log = RankForce::Log.instance
      log.path = load('log')
      log.write(msg, level)
    end

  end
end