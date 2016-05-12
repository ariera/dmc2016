module Csv
  class Importer
    def call(table_name:, file_path:)
      columns = headers(file_path)
      create_table(table_name, columns)
      copy_csv_to_table(table_name, file_path, columns)
    end

    private
    def headers(file)
      csv = File.open(file){|f| f.readline.gsub(/\r/, '')}
      CSV.parse(csv, col_sep: ";").first
    end

    def create_table(name, columns)
      run_sql("drop table if exists #{name}")
      columns_sql = columns.map{ |column| %Q["#{column}" VARCHAR] }.join(",")
      run_sql("CREATE TABLE #{name} (#{columns_sql})")
    end

    def copy_csv_to_table(name, file_path, columns)
      columns_sql = columns.map{ |column| %Q["#{column}"] }.join(",")
      run_sql("COPY #{name} (#{columns_sql}) FROM '#{file_path}' WITH CSV HEADER delimiter ';'")
    end

    def run_sql(sql)
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
