# frozen_string_literal: true

module FormProps
  module Inputs
    class Submit < Base
      def initialize(template_object, options)
        @template_object = template_object
        @options = options.with_indifferent_access
      end

      def render
        @options[:type] = field_type

        json.set!(:submit) do
          input_props(@options)
        end
      end

      private

      def field_type
        "submit"
      end
    end
  end
end
