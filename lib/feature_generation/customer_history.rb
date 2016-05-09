module FeatureGeneration
  class CustomerHistory < Table
    def self.table_name
      "#{namespace}_customer_history"
    end

    def self.table_sql
      %Q{
        SELECT
          customerid,
          sum(quantity)       AS customer_sum_quantities,
          sum(returnquantity) AS customer_sum_returns,
          CASE
          WHEN (SUM(returnquantity) = 0)
            THEN 0
          ELSE
            sum(returnquantity) / COALESCE(sum(quantity), 0) :: FLOAT
          END                    customer_return_ratio
        FROM #{namespace}
        GROUP BY customerid
      }
    end

    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_#{namespace}_ch_customer ON #{table_name} (customerid);
      }
    end
  end
end
