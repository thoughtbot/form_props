# frozen_string_literal: true

module FormProps
  module Inputs
    class TelField < TextField
      private

      def field_type
        "tel"
      end
    end
  end
end
