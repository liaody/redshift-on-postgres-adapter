require 'active_record/tasks/postgresql_database_tasks'

class ActiveRecord::Tasks::RedshiftDatabaseTasks < ActiveRecord::Tasks::PostgreSQLDatabaseTasks # :nodoc:

  def initialize(db_config)
    super(db_config)
  end

  def structure_dump(filename)
    set_psql_env

    search_path = \
    case ActiveRecord::Base.dump_schemas
    when :schema_search_path
      configuration[:schema_search_path]
    when :all
      nil
    when String
      ActiveRecord::Base.dump_schemas
    end

    File.open(filename, 'w+') do |file|
      ddl_results('admin.v_generate_tbl_ddl').each_row do |row|
        file.puts(row)
      end
    end
    File.open(filename, "a") { |f| f << "SET search_path TO #{connection.schema_search_path};\n\n" }
  end

  def structure_load(filename)
    sql = nil
    if File.exist?(output_location)
      sql = File.read(output_location)
    else
      puts 'Schema Dump file does not exist. Run task db:structure:dump'
      false
    end
    connection.execute(sql) if sql.present?
  end

  def ddl_results(ddl_tbl)
    ddl_sql = <<-SQL
        SELECT  ddl
        FROM    #{ddl_tbl}
        WHERE   schemaname = '#{connection.schema_search_path}'
        AND (ddl NOT ilike '%owner to%' AND ddl NOT ilike '--DROP TABLE%')
        ORDER BY tablename ASC, seq ASC
        SQL
    connection.execute(ddl_sql)
  end
end