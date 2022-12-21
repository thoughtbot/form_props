# frozen_string_literal: true

module FormProps
  module Inputs
    class NumberField < TextField
      def render
        if (range = @options.delete("in") || @options.delete("within"))
          @options.update("min" => range.min, "max" => range.max)
        end

        super
      end

      private

      def field_type
        "number"
      end
    end
  end
end
