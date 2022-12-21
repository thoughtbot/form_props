# frozen_string_literal: true

module FormProps
  module Inputs
    class PasswordField < TextField
      def render
        @options = {value: nil}.merge!(@options)
        super
      end

      private

      def field_type
        "password"
      end
    end
  end
end
