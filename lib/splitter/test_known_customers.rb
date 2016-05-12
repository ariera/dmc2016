module Splitter
  class TestKnownCustomers < FeatureGeneration::Table
    def self.table_name
      "test_all_features_known_customers"
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
              SELECT *
              FROM #{train_table}
              WHERE NOT (quantity::float = 0 OR price::float = 0 OR colorcode::float = 8888 OR productgroup IS NULL OR rrp IS NULL)
          ),
            known_customers AS (
              SELECT
                customerid,
                max(size_bought_times::float)       AS size_bought_times,
                max(size_returned_ratio::float)     AS size_returned_ratio,
                max(size_returned_times::float)     AS size_returned_times,
                max(color_bought_times::float)      AS color_bought_times,
                max(color_returned_ratio::float)    AS color_returned_ratio,
                max(color_returned_times::float)    AS color_returned_times,
                max(customer_return_ratio::float)   AS customer_return_ratio,
                max(customer_sum_quantities::float) AS customer_sum_quantities,
                max(customer_sum_returns::float)    AS customer_sum_returns
              FROM train_no_giveaways
              GROUP BY customerid
          )
        SELECT
          tst_ng.*,
          size_bought_times,
          size_returned_ratio,
          size_returned_times,
          color_bought_times,
          color_returned_ratio,
          color_returned_times,
          customer_return_ratio,
          customer_sum_quantities,
          customer_sum_returns
        FROM test_no_giveaways AS tst_ng
          INNER JOIN known_customers AS kc ON tst_ng.customerid = kc.customerid;
      }
    end
  end
end
__END__
Splitter::TestKnownCustomers.recreate_table
