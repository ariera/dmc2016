module FeatureGeneration
  class TestFeatures < TrainFeatures
    def self.table_sql
      %Q{
        SELECT
          t.*,
          g.gender,
          #{price_per_item_formula('t')} AS price_per_item,
          #{price_to_rrp_ratio_formula('t')} AS price_to_rrp_ratio,
          #{usual_price_ratio_formula('ah')} AS usual_price_ratio,
          SUBSTR(t.colorcode::VARCHAR, 1, 1) AS color_RAL_group,
          CASE
            WHEN (t.voucherid IS NULL)
              THEN FALSE
            WHEN (t.voucherid = '0')
              THEN FALSE
            ELSE TRUE
          END AS has_voucher,
          #{product_kind('t')} AS product_kind,
          #{date_attrs_sql('t')},
          #{productgroup_return_history('t')},
          ah.article_average_price,
          ah.article_cheapest_price,
          ah.article_most_expensive_price,
          ah.article_number_of_different_prices,
          oh.total_order_price,
          oh.subtotal_order_price,
          oh.n_articles_in_order,
          oh.voucher_to_order_price_ratio,
          oah.different_sizes,
          oah.sizes,
          oah.different_colors,
          oah.colors,
          oah.n_times_article_appears_in_order,
          csc.cluster AS customer_cluster


        FROM #{namespace} AS t
          INNER JOIN #{OrderHistory.table_name}         AS oh ON oh.orderid = t.orderid
          INNER JOIN #{ArticleHistory.table_name}       AS ah ON ah.articleid = t.articleid
          INNER JOIN #{OrderArticleHistory.table_name}  AS oah ON oah.orderid = t.orderid AND oah.articleid = t.articleid
          INNER JOIN #{Gender.table_name}               AS g  ON g.customerid = t.customerid
          INNER JOIN customer_segmentation_clustering   AS csc ON csc.customerid = t.customerid
      }
    end
  end
end
