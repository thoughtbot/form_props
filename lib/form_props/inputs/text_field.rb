# frozen_string_literal: true

require "action_view/helpers/tags/placeholderable"

module FormProps
  module Inputs
    class TextField < Base
      include ActionView::Helpers::Tags::Placeholderable

      def render
        @options[:size] = @options[:max_length] unless @options.key?(:size)
        @options[:type] ||= field_type
        @options[:value] = @options.fetch(:value) { value_before_type_cast } unless field_type == "file"

        json.set!(sanitized_key) do
          add_default_name_and_id(@options)
          input_props(@options)
        end
      end

      private

      def field_type
        "text"
      end
    end
  end
end
