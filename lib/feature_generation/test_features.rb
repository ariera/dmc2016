module FeatureGeneration
  class TestFeatures < TrainFeatures
    def self.table_sql
      %Q{
        SELECT
          t.*,
          #{price_per_item_formula('t')} AS price_per_item,
          #{price_to_rrp_ratio_formula('t')} AS price_to_rrp_ratio,
          #{usual_price_ratio_formula('ah')} AS usual_price_ratio,
          ah.article_average_price,
          ah.article_cheapest_price,
          ah.article_most_expensive_price,
          ah.article_number_of_different_prices,
          oh.total_order_price,
          oah.different_sizes,
          oah.sizes,
          oah.different_colors,
          oah.colors


        FROM #{namespace} AS t
          INNER JOIN #{OrderHistory.table_name}         AS oh ON oh.orderid = t.orderid
          INNER JOIN #{ArticleHistory.table_name}       AS ah ON ah.articleid = t.articleid
          INNER JOIN #{OrderArticleHistory.table_name}  AS oah ON oah.orderid = t.orderid AND oah.articleid = t.articleid
      }
    end
  end
end
