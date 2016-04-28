module FeatureGeneration
  class CustomerSizeHistory < Table
    def self.table_name
      "#{namespace}_customer_size_history"
    end

    def self.table_sql
      %Q{
          WITH
              size_returned AS (
                SELECT
                  customerid,
                  sizecode,
                  count(sizecode) size_returned_times
                FROM #{namespace}
                WHERE returnquantity > 0
                GROUP BY customerid, sizecode
            ),
              size_bought AS (
                SELECT
                  customerid,
                  sizecode,
                  count(sizecode) size_bought_times
                FROM #{namespace}
                GROUP BY customerid, sizecode
            )

          SELECT
            size_bought.customerid,
            size_bought.sizecode,
            COALESCE(size_returned.size_returned_times, 0)                                             AS size_returned_times,
            size_bought.size_bought_times,
            (COALESCE(size_returned.size_returned_times, 0) / size_bought_times :: FLOAT * 100) :: INT AS size_returned_ratio

          FROM size_returned
            RIGHT JOIN size_bought
              ON size_returned.customerid = size_bought.customerid AND size_returned.sizecode = size_bought.sizecode
      }
    end
    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_#{namespace}_csh_customer ON #{table_name} (customerid);
        CREATE INDEX idx_#{namespace}_csh_size ON #{table_name} (sizecode);
      }
    end
  end
end
