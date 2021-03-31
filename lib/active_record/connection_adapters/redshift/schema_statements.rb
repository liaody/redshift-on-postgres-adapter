
module ActiveRecord::ConnectionAdapters
  module Redshift
    class SchemaCreation < PostgreSQL::SchemaCreation
      ENCODING_TYPES = %w[RAW AZ64 BYTEDICT DELTA DELTA32K LZO MOSTLY8 MOSTLY16 MOSTLY32 RUNLENGTH TEXT255 TEXT32K ZSTD]

      def column_options(o)
        column_options = super
        column_options[:distkey] = o.distkey
        column_options[:sortkey] = o.sortkey

        if o.encode
          encode = o.encode.to_s.upcase
          if ENCODING_TYPES.include?(encode)
            column_options[:encode] = encode
          else
            raise "Invalid encoding type: #{o.encode}"
          end
        else
          # column_options[:encode] = 'RAW'
        end

        column_options
      end

      # Support
      def add_column_options!(sql, options)
        if options[:distkey]
          sql << ' DISTKEY'
        end

        if options[:sortkey]
          sql << ' SORTKEY'
        end

        if options[:encode]
          sql << " ENCODE #{options[:encode]}"
        end

        super
      end
    end
  end
end