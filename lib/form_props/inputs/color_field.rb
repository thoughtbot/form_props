# frozen_string_literal: true

module FormProps
  module Inputs
    class ColorField < TextField
      def render
        @options["value"] ||= validate_color_string(value)
        super
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
