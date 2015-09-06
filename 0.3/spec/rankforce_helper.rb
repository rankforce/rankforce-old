require 'rspec'
require File.dirname(__FILE__) + "/../lib/rankforce"
require File.dirname(__FILE__) + "/../lib/rankforce/crawler"
require File.dirname(__FILE__) + "/../lib/rankforce/db"
require File.dirname(__FILE__) + "/../lib/rankforce/tweet"
require File.dirname(__FILE__) + "/../lib/rankforce/utils"

module RankForce
  module Rspec
    class Log
      def initialize
        RankForce::Log.class_eval do
          def inspector(level)
            @debug[level]
          end
        end

        class << RankForce
          def log_inspector(level)
            @log.inspector(level.to_s)
          end

          def log_printer(level)
            @log.inspector(level.to_s).last
          end
        end
      end

      def get(level)
        RankForce.log_inspector(level)
      end

      def print(level)
        RankForce.log_printer(level)
      end

      def dump(level)
        get(level)
      end
    end

    class Tweet
      def get_tweeted_msg(params, send_msg = nil)
        tweet = RankForce::Tweet.new(params[:twitter])
        begin
          tweet.post(send_msg) do
            send_msg
          end
        rescue => e
          e.message
        end
      end
    end
  end
end
