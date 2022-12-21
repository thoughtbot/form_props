# frozen_string_literal: true

module FormProps
  module Inputs
    class DatetimeField < TextField
      def render
        @options[:value] ||= format_date(value)
        @options[:min] = format_date(datetime_value(@options["min"]))
        @options[:max] = format_date(datetime_value(@options["max"]))
        super
      end

      private

      def format_date(value)
        raise NotImplementedError
      end

      def datetime_value(value)
        if value.is_a? String
          begin
            DateTime.parse(value)
          rescue
            nil
          end
        else
          value
        end
      end
    end
  end
end
