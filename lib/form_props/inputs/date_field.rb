# frozen_string_literal: true

module FormProps
  module Inputs
    class DateField < DatetimeField
      private

      def format_date(value)
        value&.strftime("%Y-%m-%d")
      end

      def field_type
        "date"
      end
    end
  end
end
