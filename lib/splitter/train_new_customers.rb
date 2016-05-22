module Splitter
  class TrainNewCustomers < Table
    def self.table_name
      "#{namespace}_train_new_customers"
    end

    def self.table_sql(opts)
      test_table = opts["test_table"]
      train_table = opts["train_table"]
      %Q{
        WITH test_no_giveaways AS (
            SELECT *
            FROM #{test_table}
            WHERE
              NOT (quantity :: FLOAT = 0 OR price :: FLOAT = 0 OR colorcode :: FLOAT = 8888 OR productgroup IS NULL OR
                   rrp IS NULL)
        ),
            train_no_giveaways AS (
              SELECT *
              FROM #{train_table}
              WHERE NOT (quantity :: FLOAT = 0 OR price :: FLOAT = 0 OR colorcode :: FLOAT = 8888 OR productgroup IS NULL OR
                         rrp IS NULL)
          ),
            new_customers AS (
              SELECT customerid
              FROM test_no_giveaways
              GROUP BY customerid
          )
        SELECT
          trn_ng."colorcode",
          trn_ng."deviceid",
          --trn_ng."day in month" as day_in_month,
          --trn_ng."month_of_year",
          --trn_ng."day_of_week",
          --trn_ng."quarter",
          trn_ng."orderid",
          trn_ng."articleid",
          trn_ng."sizecode",
          trn_ng."productgroup",
          trn_ng."quantity",
          trn_ng."price",
          trn_ng."rrp",
          trn_ng."voucheramount",
          trn_ng."voucherid",
          trn_ng."customerid",
          trn_ng."paymentmethod",
          trn_ng."orderdate",
          trn_ng."price_per_item",
          trn_ng."price_to_rrp_ratio",
          trn_ng."usual_price_ratio",
          trn_ng."color_ral_group",
          trn_ng."has_voucher",
          trn_ng."article_average_price",
          trn_ng."article_cheapest_price",
          trn_ng."article_most_expensive_price",
          trn_ng."article_number_of_different_prices",
          trn_ng."total_order_price",
          trn_ng."different_sizes",
          trn_ng."sizes",
          trn_ng."different_colors",
          trn_ng."colors",
          --trn_ng."NewSizeCode",
          --trn_ng."new_paymentmethod",
          --trn_ng."year_and_month",
          trn_ng."returnquantity",
          (trn_ng."returnquantity"::float != 0) as has_return,
          trn_ng.day,
          trn_ng.month,
          trn_ng.year,
          trn_ng.day_of_week,
          trn_ng.quarter,
          trn_ng.year_and_month,
          trn_ng.end_of_month,
          trn_ng.is_productgroup_with_low_return_rate,
          trn_ng.is_productgroup_with_high_return_rate,
          trn_ng.gender,
          trn_ng.product_kind,
          trn_ng.subtotal_order_price,
          trn_ng.n_articles_in_order,
          trn_ng.voucher_to_order_price_ratio,
          trn_ng.n_times_article_appears_in_order,
          trn_ng.customer_cluster,
          trn_ng."id"
        FROM train_no_giveaways AS trn_ng
          LEFT JOIN new_customers AS kc ON trn_ng.customerid = kc.customerid
        WHERE kc.customerid IS NULL;

      }
    end

    def self.create_indexes_sql
      %Q{
        CREATE INDEX idx_#{namespace}_tnc_customer ON #{table_name} (customerid);
      }
    end
  end
end
