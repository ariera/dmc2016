module FeatureGeneration
  class Features < Table
    def self.table_name
      "#{namespace}_features"
    end

    def self.price_per_item_formula(table_name)
      %Q{
        CASE
        WHEN (#{table_name}.quantity > 0)
          THEN
            (#{table_name}.price / #{table_name}.quantity :: FLOAT)
        ELSE
          #{table_name}.price
        END
      }
    end

    def self.price_to_rrp_ratio_formula(table_name)
      %Q{
        CASE
        WHEN (#{table_name}.quantity > 0 AND #{table_name}.rrp > 0)
          THEN
            (#{table_name}.price / #{table_name}.quantity :: FLOAT) / #{table_name}.rrp
        ELSE
          0
        END
      }
    end

    def self.usual_price_ratio_formula(table_name)
      %Q{
        CASE
        WHEN (#{table_name}.article_average_price > 0)
          THEN
            #{price_per_item_formula('t')} / #{table_name}.article_average_price::float
        ELSE
          0
        END
      }
    end

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
          oah.colors,
          cch.color_returned_times,
          cch.color_bought_times,
          cch.color_returned_ratio,
          csh.size_returned_times,
          csh.size_bought_times,
          csh.size_returned_ratio

        FROM #{namespace} AS t
          INNER JOIN #{OrderHistory.table_name}         AS oh ON oh.orderid = t.orderid
          INNER JOIN #{ArticleHistory.table_name}       AS ah ON ah.articleid = t.articleid
          INNER JOIN #{OrderArticleHistory.table_name}  AS oah ON oah.orderid = t.orderid AND oah.articleid = t.articleid
          INNER JOIN #{CustomerColorHistory.table_name} AS cch ON cch.customerid = t.customerid AND cch.colorcode = t.colorcode
          INNER JOIN #{CustomerSizeHistory.table_name}  AS csh ON csh.customerid = t.customerid AND csh.sizecode = t.sizecode
      }
    end

    def self.create_indexes_sql
    end
  end
end

__END__
price_per_item:
  represents the customer paid for only 1 item of the given article without taking the voucher into consideration
  formula: price / quantity
  if quantity is zero price_per_item is set to the original value of price (0)
price_to_rrp_ratio:
  indicates if the article was selled above (> 1.0) or below (< 1.0) the recommended retail price
  formula: price_per_item / rrp
  if rrp is zero price_to_rrp_ratio is set to zero
article_average_price:
  the average price_per_item in our dataset
  formula: AVG(price_per_item) GROUP BY articleid
article_cheapest_price:
  the smallest price_per_item value found in dataset
article_most_expensive_price
  the biggest price_per_item value found in dataset
article_number_of_different_prices:
  with how many different price_per_items has this article been selled
usual_price_ratio:
  bigger than 1 if this article in this order being selled above the article_average_price
  smaller than 1 if is selled below
  fomula: price_per_item / article_average_price
  if article_average_price is zero then usual_price_ratio is set to zero
total_order_price:
  formula: SUM(price) - voucheramount
  Note that even though the prices of all the items of an order are being add up together, the voucheramount must be used only once
sizes:
  a list of the different sizes ordered for this articleid.
  ie. if in the same order i bought the same t-shirt twice, once with size M and once with size L, the value of sizes will be {M, L}
different_sizes:
  formula: COUNT(sizes)
  in the example above different_sizes would be set to 2
colors:
  a list of the different colors ordered for this articleid
  ie. if in the same order i bought the same t-shirt twice, once in blue and once red, the value of sizes will be {blue, red}
different_colors:
  formula: COUNT(colors)
  in the example above different_colors would be set to 2

The following values are generated after studuying the profile of a user
color_bought_times:
  How many times has this particular customer bought this particular color
color_returned_times:
  How many times has this particular customer returned this particular color
color_returned_ratio:
  formula: color_returned_times / color_returned_times
size_bought_times:
  How many times has this particular customer bought this particular size
size_returned_times:
  How many times has this particular customer returned this particular size
size_returned_ratio:
  formula: size_returned_times / size_bought_times
