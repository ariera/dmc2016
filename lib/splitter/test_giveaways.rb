module Splitter
  class TestGiveAways < Table
    def self.table_name
      "#{namespace}_test_giveaways"
    end

    def self.table_sql(opts)
      test_table = opts["test_table"]
      %Q{
        SELECT *
        FROM #{test_table}
        WHERE
          (quantity::float = 0 OR price::float = 0 OR colorcode::float = 8888 OR productgroup IS NULL OR rrp IS NULL)
      }
    end
  end
end
