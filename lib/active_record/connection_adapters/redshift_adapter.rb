
require 'active_record/connection_adapters/postgresql_adapter'

require 'active_record/tasks/redshift_database_tasks'

ActiveRecord::Tasks::DatabaseTasks.register_task(/redshift/,   ActiveRecord::Tasks::RedshiftDatabaseTasks)

module ActiveRecord::ConnectionHandling
  def redshift_connection(config)
    conn_params = config.symbolize_keys
    conn_params.delete_if { |_, v| v.nil? }

    # Map ActiveRecords param names to PGs.
    conn_params[:user] = conn_params.delete(:username) if conn_params[:username]
    conn_params[:dbname] = conn_params.delete(:database) if conn_params[:database]

    # Forward only valid config params to PGconn.connect.
    valid_conn_param_keys = PGconn.conndefaults_hash.keys + [:requiressl]
    conn_params.slice!(*valid_conn_param_keys)

    # The postgres drivers don't allow the creation of an unconnected PGconn object,
    # so just pass a nil connection object for the time being.
    ActiveRecord::ConnectionAdapters::RedshiftAdapter.new(nil, logger, conn_params, config)
  end
end

class ActiveRecord::ConnectionAdapters::RedshiftAdapter < ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  ADAPTER_NAME = 'Redshift'.freeze

  NATIVE_DATABASE_TYPES = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES.merge({
    primary_key: "bigint primary key identity(1,1)",
  })

  def initialize(connection, logger, connection_parameters, config)
    super
  end

  # Configures the encoding, verbosity, schema search path, and time zone of the connection.
  # This is called by #connect and should not be called manually.
  def configure_connection
    if @config[:encoding]
      @connection.set_client_encoding(@config[:encoding])
    end
    # self.client_min_messages = @config[:min_messages] || 'warning'
    self.schema_search_path = @config[:schema_search_path] || @config[:schema_order]

    # Use standard-conforming strings so we don't have to do the E'...' dance.
    # set_standard_conforming_strings

    # If using Active Record's time zone support configure the connection to return
    # TIMESTAMP WITH ZONE types in UTC.
    # (SET TIME ZONE does not use an equals sign like other SET variables)
    # if ActiveRecord::Base.default_timezone == :utc
    #   execute("SET time zone 'UTC'", 'SCHEMA')
    # elsif @local_tz
    #   execute("SET time zone '#{@local_tz}'", 'SCHEMA')
    # end

    # SET statements from :variables config hash
    # http://www.postgresql.org/docs/8.3/static/sql-set.html
    variables = @config[:variables] || {}
    variables.map do |k, v|
      if v == ':default' || v == :default
        # Sets the value to the global or compile default
        execute("SET SESSION #{k} TO DEFAULT", 'SCHEMA')
      elsif !v.nil?
        execute("SET SESSION #{k} TO #{quote(v)}", 'SCHEMA')
      end
    end
  end

  def postgresql_version
    # Hack to avoid native PostgreQLAdapter's version check
    return 100000 + 80002
  end

  def native_database_types #:nodoc:
    NATIVE_DATABASE_TYPES
  end

  def supports_statement_cache?
    false
  end

  def supports_index_sort_order?
    false
  end

  def supports_partial_index?
    false
  end

  def supports_transaction_isolation?
    false
  end

  def supports_foreign_keys?
    false
  end

  def supports_views?
    false
  end

  def supports_extensions?
    false
  end

  def supports_ranges?
    false
  end

  def supports_materialized_views?
    false
  end

  def use_insert_returning?
    false
  end

  # Returns the list of a table's column names, data types, and default values.
  #
  # The underlying query is roughly:
  #  SELECT column.name, column.type, default.value
  #    FROM column LEFT JOIN default
  #      ON column.table_id = default.table_id
  #     AND column.num = default.column_num
  #   WHERE column.table_id = get_table_id('table_name')
  #     AND column.num > 0
  #     AND NOT column.is_dropped
  #   ORDER BY column.num
  #
  # If the table name is not prefixed with a schema, the database will
  # take the first match from the schema search path.
  #
  # Query implementation notes:
  #  - format_type includes the column size constraint, e.g. varchar(50)
  #  - ::regclass is a function that gives the id for a table name
  def column_definitions(table_name) #:nodoc:
    exec_query(<<-end_sql, 'SCHEMA').rows
      SELECT a.attname, format_type(a.atttypid, a.atttypmod),
               pg_get_expr(d.adbin, d.adrelid), a.attnotnull, a.atttypid, a.atttypmod
        FROM pg_attribute a LEFT JOIN pg_attrdef d
          ON a.attrelid = d.adrelid AND a.attnum = d.adnum
       WHERE a.attrelid = '#{quote_table_name(table_name)}'::regclass
         AND a.attnum > 0 AND NOT a.attisdropped
       ORDER BY a.attnum
    end_sql
  end

  # Returns just a table's primary key
  def primary_keys(table)
    row = exec_query(<<-end_sql, 'SCHEMA').rows.map do |row|
      SELECT DISTINCT(attr.attname)
      FROM pg_attribute attr
      INNER JOIN pg_depend dep ON attr.attrelid = dep.refobjid AND attr.attnum = dep.refobjsubid
      INNER JOIN pg_constraint cons ON attr.attrelid = cons.conrelid AND attr.attnum = cons.conkey[1]
      WHERE cons.contype = 'p'
        AND dep.refobjid = '#{quote_table_name(table)}'::regclass
    end_sql
      row && row.first
    end
  end

  def indexes(table_name, name = nil)
    []
  end

  def get_advisory_lock(lock_id)
    lock_id
  end

  def release_advisory_lock(lock_id)
  end
end