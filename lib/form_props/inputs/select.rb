# frozen_string_literal: true

module FormProps
  module Inputs
    class Select < Base
      include FormOptionsHelper

      def initialize(object_name, method_name, template_object, choices, options, html_options)
        @choices = choices
        @choices = @choices.to_a if @choices.is_a?(Range)

        @html_options = html_options
        super(object_name, method_name, template_object, options)
      end

      def render
        option_tags_options = {
          selected: @options.fetch(:selected) { value.nil? ? "" : value },
          disabled: @options[:disabled]
        }

        option_tags = if grouped_choices?
          grouped_options_for_select(@choices, option_tags_options)
        else
          options_for_select(@choices, option_tags_options)
        end

        select_content_props(option_tags, @options, @html_options)
      end

      private

      # Grouped choices look like this:
      #
      #   [nil, []]
      #   { nil => [] }
      def grouped_choices?
        !@choices.blank? && @choices.first.respond_to?(:last) && Array === @choices.first.last
      end
    end
  end
end
