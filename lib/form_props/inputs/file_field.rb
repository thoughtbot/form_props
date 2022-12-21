# frozen_string_literal: true

module FormProps
  module Inputs
    class FileField < TextField
      private

      def field_type
        "file"
      end
    end
  end
end
