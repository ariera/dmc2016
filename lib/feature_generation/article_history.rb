module FeatureGeneration
  class ArticleHistory < Table
    cattr_accessor :override_namespace
    def self.table_name
      "#{override_namespace}_article_history"
    end

    def self.override_namespace
      @@override_namespace || namespace
    end

    def self.table_sql
      %Q{
        SELECT
          articleid,
          AVG(price_per_item)              AS article_average_price,
          MIN(price_per_item)              AS article_cheapest_price,
          MAX(price_per_item)              AS article_most_expensive_price,
          count(DISTINCT (price_per_item)) AS article_number_of_different_prices
        FROM (
               SELECT
                 articleid,
                 rrp,
                 CASE
                 WHEN (quantity > 0)
                   THEN
                     price / quantity :: FLOAT
                 ELSE
                   NULL
                 END AS price_per_item

               FROM #{override_namespace}
             ) t
        GROUP BY articleid
      }
    end

    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_#{table_name}_ah_article ON #{table_name} (articleid);
      }
    end
  end
end
