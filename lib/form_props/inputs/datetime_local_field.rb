# frozen_string_literal: true

module FormProps
  module Inputs
    class DatetimeLocalField < DatetimeField
      private

      def format_date(value)
        value&.strftime("%Y-%m-%dT%T")
      end

      def field_type
        "datetime-local"
      end
    end
  end
end
