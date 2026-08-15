# frozen_string_literal: true

module FormProps
  module Inputs
    class ColorField < Base
      def render
        @options[:type] ||= field_type
        @options["value"] ||= validate_color_string(value)

        json.set!(sanitized_key) do
          add_default_name_and_field(@options)
          input_props(@options)
        end
      end

      private

      def validate_color_string(string)
        regex = /#[0-9a-fA-F]{6}/
        if regex.match?(string)
          string.downcase
        else
          "#000000"
        end
      end

      def field_type
        "color"
      end
    end
  end
end
