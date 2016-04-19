require 'yaml'
require 'active_record'
require 'activerecord-import'
require 'logger'
require 'pry'

db_config = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)
ActiveRecord::Base.logger = Logger.new(STDOUT)


module Sampling
  def self.sample!
    Sampler.new.call
  end

  class LineItem < ActiveRecord::Base
    def self.table_name
      "train"
    end
  end

  class LineItemSample < ActiveRecord::Base
    def self.table_name
      "train_sample"
    end

    def self.mass_import(columns, rows)
      self.delete_all
      self.import(columns, rows)
    end
  end

  class Sampler
    attr_reader :sample
    def initialize
      @sample = Sample.new
    end
    def call
      while @sample.length < 50_000
        puts @sample.length
        customer_id = find_random_customer_id
        lineitems = LineItem.where(customerid: customer_id).to_a
        @sample.push(lineitems)
      end
      @sample.save_to_db!
    end

    private

    def find_random_customer_id
      @customer_ids ||= LineItem.all.pluck("customerid")

      # sql = "select customerid from train group by customerid offset floor(random()*311369) limit 1"
      customer_id = nil
      while customer_id.nil? || @sample.customer_ids.include?(customer_id)
        customer_id = @customer_ids.sample
      end
      customer_id
    end

    def find_random_order_id
      @number_of_lineitems ||= LineItem.count
      order_id = nil
      sql = "SELECT * FROM train OFFSET FLOOR(RANDOM()*#{@number_of_lineitems}) LIMIT 1"
      while order_id.nil? || @sample.order_ids.include?(order_id)
        # order_id = LineItem.offset("floor(RANDOM()* #{@number_of_lineitems})").limit(1).to_a.first.orderid

        order_id = LineItem.find_by_sql(sql).to_a.first.orderid
      end
      order_id
    end
  end

  class Sample
    def initialize
      @list = []
    end

    def push(item)
      @list += Array(item)
    end

    def length
      @list.length
    end

    def customer_ids
      @list.map(&:customerid).uniq
    end

    def order_ids
      @list.map(&:orderid).uniq
    end

    def save_to_db!
      columns = @list.first.attributes.keys
      rows = @list.map{ |li| li.attributes.values }
      LineItemSample.mass_import(columns, rows)
    end
  end

end


 Sampling.sample!


__END__
load "lib/sampling.rb"
Sampling.sample!
