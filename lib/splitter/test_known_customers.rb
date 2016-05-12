module Splitter
  class TestKnownCustomers < FeatureGeneration::Table
    def self.table_name
      "test_all_features_known_customers"
    end

    def self.table_sql
      test_table = "test_all_features"
      train_table = "train_all_features"
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
          tst_ng."day in month" as day_in_month,
          tst_ng."month_of_year",
          tst_ng."day_of_week",
          tst_ng."quarter",
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
          kc."size_bought_times",
          kc."size_returned_ratio",
          kc."size_returned_times",
          kc."color_bought_times",
          kc."color_returned_ratio",
          kc."color_returned_times",
          kc."customer_return_ratio",
          kc."customer_sum_quantities",
          kc."customer_sum_returns",
          tst_ng."NewSizeCode",
          tst_ng."new_paymentmethod",
          tst_ng."year_and_month",
          --tst_ng."returnquantity",
          --(tst_ng."returnquantity"::float != 0) as has_return,
          tst_ng."id"
        FROM test_no_giveaways AS tst_ng
          INNER JOIN known_customers AS kc ON tst_ng.customerid = kc.customerid;
      }
    end
  end
end
__END__
Splitter::TestKnownCustomers.recreate_table
