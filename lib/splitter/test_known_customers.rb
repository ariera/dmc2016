module Splitter
  class TestKnownCustomers < Table
    def self.table_name
      "#{namespace}_test_known_customers"
    end

    def self.table_sql(opts)
      test_table = opts["test_table"]
      train_table = opts["train_table"]

      label_selector_sql = if opts["add_label_to_test"]
        %Q{
          tst_ng."returnquantity",
          (tst_ng."returnquantity"::float != 0) as has_return,
        }
      else
        ""
      end
      %Q{
        WITH test_no_giveaways AS (
            SELECT *
            FROM #{test_table}
            WHERE
              NOT (quantity::float = 0 OR price::float = 0 OR colorcode::float = 8888 OR productgroup IS NULL OR rrp IS NULL)
        ),
            train_no_giveaways AS (
              SELECT *
              FROM #{train_table}
              WHERE NOT (quantity::float = 0 OR price::float = 0 OR colorcode::float = 8888 OR productgroup IS NULL OR rrp IS NULL)
          ),
            known_customers AS (
              SELECT
                customerid,
                max(size_bought_times::float)       AS size_bought_times,
                max(size_returned_ratio::float)     AS size_returned_ratio,
                max(size_returned_times::float)     AS size_returned_times,
                max(color_bought_times::float)      AS color_bought_times,
                max(color_returned_ratio::float)    AS color_returned_ratio,
                max(color_returned_times::float)    AS color_returned_times,
                max(customer_return_ratio::float)   AS customer_return_ratio,
                max(customer_sum_quantities::float) AS customer_sum_quantities,
                max(customer_sum_returns::float)    AS customer_sum_returns
              FROM train_no_giveaways
              GROUP BY customerid
          )
        SELECT
          tst_ng."colorcode",
          tst_ng."deviceid",
          --tst_ng."day in month" as day_in_month,
          --tst_ng."month_of_year",
          --tst_ng."day_of_week",
          --tst_ng."quarter",
          tst_ng."orderid",
          tst_ng."articleid",
          tst_ng."sizecode",
          tst_ng."productgroup",
          tst_ng."quantity",
          tst_ng."price",
          tst_ng."rrp",
          tst_ng."voucheramount",
          tst_ng."voucherid",
          tst_ng."customerid",
          tst_ng."paymentmethod",
          tst_ng."orderdate",
          tst_ng."price_per_item",
          tst_ng."price_to_rrp_ratio",
          tst_ng."usual_price_ratio",
          tst_ng."color_ral_group",
          tst_ng."has_voucher",
          tst_ng."article_average_price",
          tst_ng."article_cheapest_price",
          tst_ng."article_most_expensive_price",
          tst_ng."article_number_of_different_prices",
          tst_ng."total_order_price",
          tst_ng."different_sizes",
          tst_ng."sizes",
          tst_ng."different_colors",
          tst_ng."colors",
          tst_ng.day,
          tst_ng.month,
          tst_ng.year,
          tst_ng.day_of_week,
          tst_ng.quarter,
          tst_ng.year_and_month,
          tst_ng.end_of_month,
          tst_ng.is_productgroup_with_low_return_rate,
          tst_ng.is_productgroup_with_high_return_rate,
          tst_ng.gender,
          tst_ng.product_kind,
          tst_ng.subtotal_order_price,
          tst_ng.n_articles_in_order,
          tst_ng.voucher_to_order_price_ratio,
          tst_ng.n_times_article_appears_in_order,
          tst_ng.customer_cluster,
          kc."size_bought_times",
          kc."size_returned_ratio",
          kc."size_returned_times",
          kc."color_bought_times",
          kc."color_returned_ratio",
          kc."color_returned_times",
          kc."customer_return_ratio",
          kc."customer_sum_quantities",
          kc."customer_sum_returns",
          --tst_ng."NewSizeCode",
          --tst_ng."new_paymentmethod",
          --tst_ng."year_and_month",
          #{label_selector_sql}
          tst_ng."id"
        FROM test_no_giveaways AS tst_ng
          INNER JOIN known_customers AS kc ON tst_ng.customerid = kc.customerid;
      }
    end
  end
end
__END__
Splitter::TestKnownCustomers.recreate_table
