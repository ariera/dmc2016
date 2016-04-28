module FeatureGeneration
  class OrderHistory < Table
    def self.table_name
      "#{namespace}_order_history"
    end

    def self.table_sql
      %Q{
        SELECT
          orderid,
          SUM(price) - MAX(voucheramount) AS total_order_price
        FROM #{namespace}
        GROUP BY orderid
      }
    end

    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_#{namespace}_oh_order ON #{table_name} (orderid);
      }
    end
  end
end
