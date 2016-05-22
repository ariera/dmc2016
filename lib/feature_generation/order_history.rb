module FeatureGeneration
  class OrderHistory < Table
    def self.table_name
      "#{namespace}_order_history"
    end

    def self.table_sql
      %Q{
        SELECT
          orderid,
          SUM(price) AS subtotal_order_price,
          SUM(price) - MAX(voucheramount) AS total_order_price,
          CASE
            WHEN SUM(price) != 0
            THEN MAX(voucheramount) / SUM(price)::float
            ELSE 0
          END AS voucher_to_order_price_ratio,
          count(*) AS n_articles_in_order
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
