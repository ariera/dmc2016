require 'set'
require_relative './shared.rb'

module FeatureGeneration
  NAMESPACE = 'foo'
end

require_relative './feature_generation/table.rb'
require_relative './splitter/test_known_customers.rb'
require_relative './splitter/test_new_customers.rb'
require_relative './splitter/test_giveaways.rb'
require_relative './splitter/train_known_customers.rb'
require_relative './splitter/train_new_customers.rb'
require_relative './splitter/train_giveaways.rb'

module Splitter

  def self.split_known_and_new_customers
    Splitter::TestKnownCustomers.recreate_table
    Splitter::TestNewCustomers.recreate_table
    Splitter::TestGiveAways.recreate_table
    Splitter::TrainKnownCustomers.recreate_table
    Splitter::TrainNewCustomers.recreate_table
    Splitter::TrainGiveAways.recreate_table

    _check_that_counts_match
    _check_that_columns_match
    _check_disjunction_of_sets
  end

  def self._check_that_counts_match
    original_train_count = 2_325_165
    original_test_count = 682_196
    train_count = Splitter::TrainKnownCustomers.count + Splitter::TrainNewCustomers.count + Splitter::TrainGiveAways.count
    test_count = Splitter::TestKnownCustomers.count + Splitter::TestNewCustomers.count + Splitter::TestGiveAways.count
    if train_count == original_train_count
      logger.info "yuhu! train count matches!"
    else
      logger.error "oh oh!: train count doesnt match: #{train_count} != #{original_train_count}"
    end
    if test_count == original_test_count
      logger.info "yuhu! test count matches!"
    else
      logger.error "oh oh!: test count doesnt match: #{test_count} != #{original_test_count}"
    end
  end

  def self._check_that_columns_match
    train_known_columns = Set.new(Splitter::TrainKnownCustomers.columns.map(&:name)) - ["returnquantity"]
    test_known_columns = Set.new(Splitter::TestKnownCustomers.columns.map(&:name))

    train_new_customers = Set.new(Splitter::TrainNewCustomers.columns.map(&:name)) - ["returnquantity"]
    test_new_customers = Set.new(Splitter::TestNewCustomers.columns.map(&:name))

    if train_known_columns == test_known_columns
      logger.info "yuhu! known_customers columns match!"
    else
      logger.error "oh oh!: known_customer columns DONT match!!! This are the extra ones: #{(train_known_columns - test_known_columns).to_a}"
    end

    if train_new_customers == test_new_customers
      logger.info "yuhu! new_customers columns match!"
    else
      logger.error "oh oh!: new_customer columns DONT match!!! This are the extra ones: #{(train_new_customers - test_new_customers).to_a}"
    end
  end

  def self._check_disjunction_of_sets
    tst_new = ActiveRecord::Base.connection.execute("SELECT count(*) FROM #{Splitter::TestNewCustomers.table_name} AS tst INNER JOIN train ON train.customerid = tst.customerid;").to_a.first["count"].to_i
    trn_new = ActiveRecord::Base.connection.execute("SELECT count(*) FROM #{Splitter::TrainNewCustomers.table_name} AS tst INNER JOIN train ON train.customerid = tst.customerid;").to_a.first["count"].to_i
    if tst_new.zero?
      logger.info "yuhu! test_new doesnt contain any known customer"
    else
      logger.info "oh oh!: test_new contains new customers!!!!!!!!!!!"
    end
    if trn_new.zero?
      logger.info "yuhu! train_new doesnt contain any known customer"
    else
      logger.info "oh oh!: train_new contains new customers!!!!!!!!!!!"
    end
  end

  def self.logger
    ActiveRecord::Base.logger
  end
end
