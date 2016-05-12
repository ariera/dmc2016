module Splitter
  class TrainKnownCustomers < FeatureGeneration::Table
    def self.table_name
      "train_all_features_known_customers"
    end

    def self.table_sql
      test_table = "test_all_features"
      train_table = "train_all_features"
      %Q{
        WITH test_no_giveaways AS (
            SELECT *
            FROM #{test_table}
            WHERE
              NOT (quantity :: FLOAT = 0 OR price :: FLOAT = 0 OR colorcode :: FLOAT = 8888 OR productgroup IS NULL OR
                   rrp IS NULL)
        ),
            train_no_giveaways AS (
              SELECT *
              FROM #{train_table}
              WHERE NOT (quantity :: FLOAT = 0 OR price :: FLOAT = 0 OR colorcode :: FLOAT = 8888 OR productgroup IS NULL OR
                         rrp IS NULL)
          ),
            new_customers AS (
              SELECT customerid
              FROM test_no_giveaways
              GROUP BY customerid
          )
        SELECT trn_ng.*
        FROM train_no_giveaways AS trn_ng
          INNER JOIN new_customers AS kc ON trn_ng.customerid = kc.customerid;
      }
    end
  end
end
