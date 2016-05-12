module Csv
  class Exporter
    def call(table_name:, file_path:)
      run_sql("COPY #{table_name} TO '#{file_path}' WITH (FORMAT CSV, HEADER, DELIMITER ';')")
    end

    private

    def run_sql(sql)
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
