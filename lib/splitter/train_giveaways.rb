module Splitter
  class TrainGiveAways < Table
    def self.table_name
      "#{namespace}_train_giveaways"
    end

    def self.table_sql(opts)
      train_table = opts["train_table"]
      %Q{
        SELECT *
        FROM #{train_table}
        WHERE
          (quantity::float = 0 OR price::float = 0 OR colorcode::float = 8888 OR productgroup IS NULL OR rrp IS NULL)
      }
    end
  end
end
