# frozen_string_literal: true

module FormProps
  module Inputs
    class RangeField < NumberField
      private

      def field_type
        "range"
      end
    end
  end
end
