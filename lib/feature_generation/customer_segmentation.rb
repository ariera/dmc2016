module FeatureGeneration
  class CustomerSegmentation < Table
    def self.table_name
      "customer_segmentation"
    end

    def self.table_sql
      %Q{
        SELECT
          customerid,
          count(*) AS customer_n_of_orders,
          avg(quantity) AS customer_avg_quantity,
          avg(price) AS customer_avg_price,
          avg(n_diff_articles) AS customer_avg_diff_articles
        FROM (
               SELECT
                 orderid,
                 customerid,
                 sum(quantity) AS quantity,
                 sum(price)    AS price,
                 count(DISTINCT(articleid)) AS n_diff_articles

               FROM test_and_train
               GROUP BY customerid, orderid
             ) AS t
        GROUP BY customerid
        ORDER BY avg(quantity) DESC;
      }
    end

    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_#{namespace}_cs_customer ON #{table_name} (customerid);
      }
    end
  end
end
