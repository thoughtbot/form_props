# frozen_string_literal: true

module FormProps
  module Inputs
    class NumberField < Base
      def render
        @options[:type] ||= field_type
        @options[:value] = @options.fetch(:value) { value_before_type_cast }

        if (range = @options.delete("in") || @options.delete("within"))
          @options.update("min" => range.min, "max" => range.max)
        end

        json.set!(sanitized_key) do
          add_default_name_and_field(@options)
          input_props(@options)
        end
      end

      private

      def field_type
        "number"
      end
    end
  end
end
