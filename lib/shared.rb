require 'yaml'
require 'active_record'
require 'activerecord-import'
require 'logger'
require 'pry'
require 'benchmark'

db_config = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)
ActiveRecord::Base.logger = Logger.new(STDOUT)
