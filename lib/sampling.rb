require 'yaml'
require 'active_record'
db_config = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)


module Sampling


  class Train < ActiveRecord::Base
    def self.table_name
      "train"
    end
  end

end

puts Sampling::Train.first.to_json
