module Splitter
  class TestNewCustomers < FeatureGeneration::Table
    def self.table_name
      "test_all_features_new_customers"
    end

    def self.table_sql
      test_table = "test_all_features"
      train_table = "train_all_features"
      %Q{
        WITH test_no_giveaways AS (
            SELECT *
            FROM #{test_table}
            WHERE
              NOT (quantity::float = 0 OR price::float = 0 OR colorcode::float = 8888 OR productgroup IS NULL OR rrp IS NULL)
        ),
            train_no_giveaways AS (
              SELECT customerid
              FROM #{train_table}
              WHERE NOT (quantity::float = 0 OR price::float = 0 OR colorcode::float = 8888 OR productgroup IS NULL OR rrp IS NULL)
          ),
            known_customers AS (
              SELECT customerid
              FROM train_no_giveaways
              GROUP BY customerid
          )
        SELECT sng.*
        FROM test_no_giveaways AS sng
          LEFT JOIN known_customers AS kc ON sng.customerid = kc.customerid
        WHERE kc.customerid IS NULL;
      }
    end
  end
end
__END__
Splitter::TestNewCustomers.recreate_table
