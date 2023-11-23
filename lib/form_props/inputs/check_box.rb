# frozen_string_literal: true

module FormProps
  module Inputs
    class CheckBox < Base
      def initialize(object_name, method_name, template_object, checked_value, unchecked_value, options)
        @checked_value = checked_value
        @unchecked_value = unchecked_value
        super(object_name, method_name, template_object, options)
      end

      def input_checked?(options)
        if options.has_key?(:checked)
          checked = options.delete(:checked)
          checked == true || checked == "checked"
        else
          checked?(value)
        end
      end

      def render(flatten = false)
        options = @options.stringify_keys
        options[:type] = "checkbox"
        options[:value] = @checked_value
        options[:checked] = true if input_checked?(options)
        options[:unchecked_value] = @unchecked_value || ""
        options[:include_hidden] = options.fetch(:include_hidden) { true }

        body_block = -> {
          if options[:multiple]
            add_default_name_and_id_for_value(@checked_value, options)
            options.delete(:multiple)
          else
            add_default_name_and_id(options)
          end

          input_props(options)
        }

        if flatten
          body_block.call
        else
          json.set!(sanitized_key) do
            body_block.call
          end
        end
      end

      private

      def checked?(value)
        case value
        when TrueClass, FalseClass
          value == !!@checked_value
        when NilClass
          false
        when String
          value == @checked_value
        else
          if value.respond_to?(:include?)
            value.include?(@checked_value)
          else
            value.to_i == @checked_value.to_i
          end
        end
      end
    end
  end
end
