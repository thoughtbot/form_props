# frozen_string_literal: true

module FormProps
  module Inputs
    class TimeZoneSelect < Base
      include ActionView::Helpers::Tags::SelectRenderer
      include ActionView::Helpers::FormOptionsHelper
      include FormOptionsHelper
      include SelectRenderer

      def initialize(object_name, method_name, template_object, priority_zones, options, html_options)
        @priority_zones = priority_zones
        @html_options = html_options

        super(object_name, method_name, template_object, options)
      end

      def render
        select_content_props(
          time_zone_options_for_select(value || @options[:default], @priority_zones, @options[:model] || ActiveSupport::TimeZone), @options, @html_options
        )
      end
    end
  end
end
