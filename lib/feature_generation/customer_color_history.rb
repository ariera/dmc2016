module FeatureGeneration
  class CustomerColorHistory < Table
    def self.table_name
      "#{namespace}_customer_color_history"
    end

    def self.table_sql
      %Q{
          WITH
              color_returned AS (
                SELECT
                  customerid,
                  colorcode,
                  count(colorcode) color_returned_times
                FROM #{namespace}
                WHERE returnquantity > 0
                GROUP BY customerid, colorcode

            ),
              color_bought AS (
                SELECT
                  customerid,
                  colorcode,
                  count(colorcode) color_bought_times
                FROM #{namespace}
                GROUP BY customerid, colorcode

            )
          SELECT
            color_bought.customerid,
            color_bought.colorcode,
            COALESCE(color_returned.color_returned_times, 0) AS color_returned_times,
            color_bought.color_bought_times,
            (COALESCE(color_returned.color_returned_times, 0) / color_bought_times :: FLOAT *
             100) :: INT                                     AS color_returned_ratio

          FROM color_returned
            RIGHT JOIN color_bought
              ON color_returned.customerid = color_bought.customerid AND color_returned.colorcode = color_bought.colorcode
      }
    end

    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_#{namespace}_cch_customer ON #{table_name} (customerid);
        CREATE INDEX idx_#{namespace}_cch_color ON #{table_name} (colorcode);
      }
    end
  end
end
