require 'logger'
require 'fileutils'
require 'singleton'

module RankForce
  class Log
    include Singleton
    attr_accessor :path

    def write(content, level)
      content = "[#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}] #{content}"
      if (!@path.nil? && File.exist?(@path))
        # Write logfile
        case level
        when "fatal"
          logger = Logger.new(logfile('fatal', @path))
          logger.level = Logger::FATAL
          logger.fatal(content)
        when "error"
          logger = Logger.new(logfile('error', @path))
          logger.level = Logger::ERROR
          logger.error(content)
        when "warn"
          logger = Logger.new(logfile('warn', @path))
          logger.level = Logger::WARN
          logger.warn(content)
        when "info"
          logger = Logger.new(logfile('info', @path))
          logger.level = Logger::INFO
          logger.info(content)
        when "debug"
          logger = Logger.new(logfile('debug', @path))
          logger.level = Logger::DEBUG
          logger.debug(content)
        end
      end
    end

    private

    def logfile(level, path)
      File.join(path, "#{level}_#{Time.now.strftime("%Y%m%d")}.log")
    end

  end
end