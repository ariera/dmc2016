module FeatureGeneration
  class Gender < Table
    def self.table_name
      "genders"
    end

    def self.table_sql
      %Q{
        WITH product_insight AS (
            SELECT
              customerid,
              CASE
              WHEN round(productgroup :: FLOAT) :: VARCHAR IN ('2', '1237')
                THEN 'product_bottom'
              WHEN round(productgroup :: FLOAT) = 1258 OR
                   (sizecode IN ('75', '80', '85', '90', '95', '100') AND round(productgroup :: FLOAT) = 17)
                THEN 'product_bra'
              WHEN round(productgroup :: FLOAT) :: VARCHAR IN ('7', '17')
                THEN 'product_top'
              ELSE 'product_unknown'
              END AS product_kind
            FROM test_and_train
        ),
          females AS (
            SELECT
              customerid AS customerid,
              'female'   AS gender
            FROM product_insight AS pi
            WHERE pi.product_kind = 'product_bra'
            GROUP BY customerid
        ),
          unknown_gender AS (
            SELECT
              DISTINCT
              (pi.customerid) AS customerid,
              'unknown'       AS gender
            FROM product_insight AS pi
              LEFT JOIN females AS f ON f.customerid = pi.customerid
            WHERE f.customerid IS NULL
        )
        SELECT
          customerid :: VARCHAR,
          gender :: VARCHAR
        FROM unknown_gender
        UNION ALL
          SELECT
            customerid :: VARCHAR,
            gender :: VARCHAR
          FROM females;
      }
    end

    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_genders_customer ON #{table_name} (customerid);
      }
    end
  end
end
