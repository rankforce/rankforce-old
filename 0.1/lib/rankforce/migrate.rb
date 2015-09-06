require 'rankforce/db'

module RankForce
  class Migrate < RankForce::DB
    def initialize
      super
    end

    def create_table
      begin
        @db.create_table @table do
          primary_key :id
          String :title
          String :board
          String :board_id
          integer :ikioi
          String :url
          timestamp :thread_date, :null => true
          timestamp :register_date, :null => true
        end
        @db.add_index @table, :title, :unique => true
        @db.add_index @table, :thread_date
      rescue Sequel::DatabaseError
        false
      end
      true
    end

    def drop_table
      begin
        @db.drop_table @table
      rescue Sequel::DatabaseError
        false
      end
      true
    end
  end
end