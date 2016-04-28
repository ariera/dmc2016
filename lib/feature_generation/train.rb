module FeatureGeneration
  class Train < Table
    def self.table_name
      "train"
    end

    def self.table_sql
      %Q{
        SELECT *
        FROM original_train
        WHERE NOT (productgroup IS NULL
                   OR quantity < returnquantity
                   OR voucherid IS NULL)
      }
    end

    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_#{namespace}_customer  ON #{table_name} (customerid);
        CREATE INDEX idx_#{namespace}_article   ON #{table_name} (articleid);
        CREATE INDEX idx_#{namespace}_colorcode ON #{table_name} (colorcode);
        CREATE INDEX idx_#{namespace}_sizecode  ON #{table_name} (sizecode);
      }
    end
  end
end
