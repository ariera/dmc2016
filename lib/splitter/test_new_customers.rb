module Splitter
  class TestNewCustomers < Table
    def self.table_name
      "#{namespace}_test_new_customers"
    end

    def self.table_sql(opts)
      test_table = opts["test_table"]
      train_table = opts["train_table"]

      label_selector_sql = if opts["add_label_to_test"]
        %Q{
          sng."returnquantity",
          (sng."returnquantity"::float != 0) as has_return,
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
              SELECT customerid
              FROM #{train_table}
              WHERE NOT (quantity::float = 0 OR price::float = 0 OR colorcode::float = 8888 OR productgroup IS NULL OR rrp IS NULL)
          ),
            known_customers AS (
              SELECT customerid
              FROM train_no_giveaways
              GROUP BY customerid
          )
        SELECT
          sng."colorcode",
          sng."deviceid",
          --sng."day in month" as day_in_month,
          --sng."month_of_year",
          --sng."day_of_week",
          --sng."quarter",
          sng."orderid",
          sng."articleid",
          sng."sizecode",
          sng."productgroup",
          sng."quantity",
          sng."price",
          sng."rrp",
          sng."voucheramount",
          sng."voucherid",
          sng."customerid",
          sng."paymentmethod",
          sng."orderdate",
          sng."price_per_item",
          sng."price_to_rrp_ratio",
          sng."usual_price_ratio",
          sng."color_ral_group",
          sng."has_voucher",
          sng."article_average_price",
          sng."article_cheapest_price",
          sng."article_most_expensive_price",
          sng."article_number_of_different_prices",
          sng."total_order_price",
          sng."different_sizes",
          sng."sizes",
          sng."different_colors",
          sng."colors",
          --sng."NewSizeCode",
          --sng."new_paymentmethod",
          --sng."year_and_month",
          sng.day,
          sng.month,
          sng.year,
          sng.day_of_week,
          sng.quarter,
          sng.year_and_month,
          sng.end_of_month,
          sng.is_productgroup_with_low_return_rate,
          sng.is_productgroup_with_high_return_rate,
          sng.gender,
          sng.product_kind,
          sng.subtotal_order_price,
          sng.n_articles_in_order,
          sng.voucher_to_order_price_ratio,
          sng.n_times_article_appears_in_order,
          sng.customer_cluster,
          #{label_selector_sql}
          sng."id"
        FROM test_no_giveaways AS sng
          LEFT JOIN known_customers AS kc ON sng.customerid = kc.customerid
        WHERE kc.customerid IS NULL;
      }
    end
  end
end
__END__
Splitter::TestNewCustomers.recreate_table
