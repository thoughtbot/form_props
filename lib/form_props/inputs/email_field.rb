# frozen_string_literal: true

module FormProps
  module Inputs
    class EmailField < TextField
      private

      def field_type
        "email"
      end
    end
  end
end
