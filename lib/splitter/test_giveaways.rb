module Splitter
  class TestGiveAways < FeatureGeneration::Table
    def self.table_name
      "test_all_features_giveaways"
    end

    def self.table_sql
      %Q{
        SELECT *
        FROM test_all_features
        WHERE
          (quantity::float = 0 OR price::float = 0 OR colorcode::float = 8888 OR productgroup IS NULL OR rrp IS NULL)
      }
    end
  end
end
