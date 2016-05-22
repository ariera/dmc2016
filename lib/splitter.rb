require 'set'
require_relative './shared.rb'

require_relative './splitter/table.rb'
require_relative './splitter/test_known_customers.rb'
require_relative './splitter/test_new_customers.rb'
require_relative './splitter/test_giveaways.rb'
require_relative './splitter/train_known_customers.rb'
require_relative './splitter/train_new_customers.rb'
require_relative './splitter/train_giveaways.rb'

module Splitter

  def self.split_known_and_new_customers(train_table:, test_table:, namespace:, add_label_to_test:)
    Table.namespace = namespace
    args = { "train_table" => train_table, "test_table" => test_table, "add_label_to_test" => add_label_to_test}
    Splitter::TestKnownCustomers.recreate_table(args)
    Splitter::TestNewCustomers.recreate_table(args)
    Splitter::TestGiveAways.recreate_table(args)
    Splitter::TrainKnownCustomers.recreate_table(args)
    Splitter::TrainNewCustomers.recreate_table(args)
    Splitter::TrainGiveAways.recreate_table(args)

    _check_that_counts_match(train_table, test_table)
    _check_that_columns_match(add_label_to_test)
    _check_disjunction_of_sets(train_table)
  end

  def self._check_that_counts_match(train_table, test_table)
    original_train_count = ActiveRecord::Base.connection.execute("SELECT count(*) FROM #{train_table} ").to_a.first["count"].to_i
    original_test_count = ActiveRecord::Base.connection.execute("SELECT count(*) FROM #{test_table} ").to_a.first["count"].to_i
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

  def self._check_that_columns_match(add_label_to_test)
    train_known_columns = Set.new(Splitter::TrainKnownCustomers.columns.map(&:name))
    test_known_columns = Set.new(Splitter::TestKnownCustomers.columns.map(&:name))

    train_new_customers = Set.new(Splitter::TrainNewCustomers.columns.map(&:name))
    test_new_customers = Set.new(Splitter::TestNewCustomers.columns.map(&:name))
    unless add_label_to_test
      train_known_columns = train_known_columns - ["returnquantity", "has_return"]
      test_known_columns  = test_known_columns  - ["returnquantity", "has_return"]
      train_new_customers = train_new_customers - ["returnquantity", "has_return"]
      test_new_customers  = test_new_customers  - ["returnquantity", "has_return"]
    end
    if train_known_columns == test_known_columns
      logger.info "yuhu! known_customers columns match!"
    else
      logger.error "oh oh!: known_customer columns DONT match!!! This are the extra ones: #{(train_known_columns ^ test_known_columns).to_a}"
    end

    if train_new_customers == test_new_customers
      logger.info "yuhu! new_customers columns match!"
    else
      logger.error "oh oh!: new_customer columns DONT match!!! This are the extra ones: #{(train_new_customers - test_new_customers).to_a}"
    end
  end

  def self._check_disjunction_of_sets(train_table)
    tst_new = ActiveRecord::Base.connection.execute("SELECT count(*) FROM #{Splitter::TestNewCustomers.table_name} AS tst INNER JOIN #{train_table} ON #{train_table}.customerid = tst.customerid;").to_a.first["count"].to_i
    if tst_new.zero?
      logger.info "yuhu! test_new doesnt contain any known customer"
    else
      logger.info "oh oh!: test_new contains known customers!!!!!!!!!!! (#{tst_new})"
    end
    trn_new = ActiveRecord::Base.connection.execute("SELECT count(*) FROM #{Splitter::TrainNewCustomers.table_name} AS tst INNER JOIN #{train_table} ON #{train_table}.customerid = tst.customerid;").to_a.first["count"].to_i
    if trn_new.zero?
      logger.info "yuhu! train_new doesnt contain any known customer"
    else
      logger.info "oh oh!: train_new contains new customers!!!!!!!!!!! (#{trn_new})"
    end
  end

  def self.logger
    ActiveRecord::Base.logger
  end
end
