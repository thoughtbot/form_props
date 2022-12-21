# frozen_string_literal: true

module FormProps
  module Inputs
    class MonthField < DatetimeField
      private

      def format_date(value)
        value&.strftime("%Y-%m")
      end

      def field_type
        "month"
      end
    end
  end
end
