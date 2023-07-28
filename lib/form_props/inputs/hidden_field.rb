# frozen_string_literal: true

module FormProps
  module Inputs
    class HiddenField < TextField
      def render
        @options[:auto_complete] = "off"
        super
      end

      def field_type
        "hidden"
      end
    end
  end
end
