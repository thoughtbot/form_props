# frozen_string_literal: true

module FormProps
  module Inputs
    class FileField < Base
      def render
        @options[:type] ||= field_type

        json.set!(sanitized_key) do
          add_default_name_and_field(@options)
          input_props(@options)
        end
      end

      private

      def field_type
        "file"
      end
    end
  end
end
