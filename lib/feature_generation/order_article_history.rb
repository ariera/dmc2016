module FeatureGeneration
  class OrderArticleHistory < Table
    def self.table_name
      "#{namespace}_order_article_history"
    end

    def self.table_sql
      %Q{
        SELECT
          orderid,
          articleid,
          sum(quantity)                   AS item_count,
          count(DISTINCT (
            CASE
            WHEN (quantity > 0)
              THEN sizecode
            ELSE NULL
            END
          ))                              AS different_sizes,
          ARRAY_AGG(DISTINCT (sizecode))  AS sizes,
          count(DISTINCT (colorcode))     AS different_colors,
          ARRAY_AGG(DISTINCT (colorcode)) AS colors,
          count(*)                        AS n_times_article_appears_in_order

        FROM #{namespace}
        GROUP BY orderid, articleid
      }
    end

    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_#{namespace}_oah_order ON #{table_name} (orderid);
        CREATE INDEX idx_#{namespace}_oah_article ON #{table_name} (articleid);
      }
    end
  end
end
