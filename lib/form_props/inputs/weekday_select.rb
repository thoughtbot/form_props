# frozen_string_literal: true

module FormProps
  module Inputs
    class WeekdaySelect < Base
      include FormOptionsHelper

      def initialize(object_name, method_name, template_object, options, html_options)
        @html_options = html_options

        super(object_name, method_name, template_object, options)
      end

      def render
        select_content_props(
          weekday_options_for_select(
            value || @options[:selected],
            index_as_value: @options.fetch(:index_as_value, false),
            day_format: @options.fetch(:day_format, :day_names),
            beginning_of_week: @options.fetch(:beginning_of_week, Date.beginning_of_week)
          ),
          @options,
          @html_options
        )
      end
    end
  end
end
