# frozen_string_literal: true

module FormProps
  module Inputs
    class HiddenField < Base
      def render
        @options[:type] ||= field_type
        @options[:value] = @options.fetch(:value) { value_before_type_cast }
        @options[:auto_complete] = "off"

        json.set!(sanitized_key) do
          add_default_name_and_field(@options)
          input_props(@options)
        end
      end

      def field_type
        "hidden"
      end
    end
  end
end
