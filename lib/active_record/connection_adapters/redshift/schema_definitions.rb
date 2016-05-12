
module ActiveRecord::ConnectionAdapters
  module Redshift

    class ColumnDefinition < PostgreSQL::ColumnDefinition
      attr_accessor :distkey, :sortkey, :encode
    end

    class TableDefinition < PostgreSQL::TableDefinition
      def new_column_definition(name, type, options) # :nodoc:
        column = super
        column.distkey = options[:distkey]
        column.sortkey = options[:sortkey]
        column.encode = options[:encode]
        column
      end

      private

        def create_column_definition(name, type)
          ColumnDefinition.new(name, type)
        end
    end

    class Table < PostgreSQL::Table
    end
  end
end
