module FeatureGeneration
  class Train < Table
    def self.table_name
      "train"
    end

    def self.table_sql
      %Q{
        SELECT *
        FROM original_train
      }
    end

    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_#{table_name}_customer  ON #{table_name} (customerid);
        CREATE INDEX idx_#{table_name}_article   ON #{table_name} (articleid);
        CREATE INDEX idx_#{table_name}_colorcode ON #{table_name} (colorcode);
        CREATE INDEX idx_#{table_name}_sizecode  ON #{table_name} (sizecode);
      }
    end
  end
end
