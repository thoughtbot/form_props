# frozen_string_literal: true

module FormProps
  module Inputs
    class UrlField < TextField
      private

      def field_type
        "url"
      end
    end
  end
end
