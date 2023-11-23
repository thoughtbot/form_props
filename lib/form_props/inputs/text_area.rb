# frozen_string_literal: true

require "action_view/helpers/tags/placeholderable"

module FormProps
  module Inputs
    class TextArea < Base
      include ActionView::Helpers::Tags::Placeholderable

      def render
        json.set!(sanitized_key) do
          add_default_name_and_id(@options)
          @options[:type] ||= field_type
          @options[:value] = @options.fetch(:value) { value_before_type_cast }

          if (size = @options.delete(:size))
            @options[:cols], @options[:rows] = size.split("x") if size.respond_to?(:split)
          end

          input_props(@options)
        end
      end

      class << self
        def field_type
          @field_type ||= name.split("::").last.sub("Field", "").downcase
        end
      end

      private

      def field_type
        self.class.field_type
      end
    end
  end
end
