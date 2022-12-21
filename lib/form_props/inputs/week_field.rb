# frozen_string_literal: true

module FormProps
  module Inputs
    class WeekField < DatetimeField
      private

      def format_date(value)
        value&.strftime("%Y-W%V")
      end

      def field_type
        "week"
      end
    end
  end
end
