# frozen_string_literal: true

module FormProps
  module Inputs
    class TimeField < DatetimeField
      private

      def format_date(value)
        value&.strftime("%T.%L")
      end

      def field_type
        "time"
      end
    end
  end
end
