module FeatureGeneration
  class Table < ActiveRecord::Base
    cattr_accessor :namespace
    @@namespace ||= NAMESPACE

    def self.table_name
      raise "define me"
    end

    def self.table_sql
      raise "define me"
    end

    def self.create_indexes_sql
    end

    def self.exists_table?
      sql_silence do
        sql = %Q{
          SELECT EXISTS (
               SELECT 1
               FROM   information_schema.tables
               WHERE  table_schema = 'public'
               AND    table_name = '#{table_name}'
          );
        }
        result = ActiveRecord::Base.connection.execute(sql)
        result.first["exists"] == "t"
      end
    end

    def self.create_table
      if exists_table?
        ActiveRecord::Base.logger.warn("table '#{table_name}' already exists. If you want to create it again consider using `recreate_table`")
      else
        create_table!
      end
    end

    def self.create_table!
      sql = %Q{
        CREATE TABLE #{table_name} AS
        #{table_sql}
      }
      ActiveRecord::Base.connection.execute(sql)
      create_indexes!
    end

    def self.create_indexes!
      if create_indexes_sql.present?
        ActiveRecord::Base.connection.execute(create_indexes_sql)
      end
    end

    def self.drop_table
      sql = %Q{
        DROP TABLE IF EXISTS #{table_name};
      }
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.recreate_table
      drop_table
      create_table!
    end


    ##
    def self.sql_silence
      ActiveRecord::Base.logger.level = Logger::INFO
      yield if block_given?
      ActiveRecord::Base.logger.level = Logger::DEBUG
    end
  end
end
