# frozen_string_literal: true

module FormProps
  module Inputs
    class RadioButton < Base
      def initialize(object_name, method_name, template_object, tag_value, options)
        @tag_value = tag_value
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
        @options[:type] = "radio"
        @options[:value] = @tag_value
        @options[:checked] = true if input_checked?(@options)

        name_for_key = (sanitized_method_name + "_#{sanitized_value(@tag_value)}").camelize(:lower)

        body_block = -> {
          add_default_name_and_id_for_value(@tag_value, @options)
          input_props(@options)
        }

        if flatten
          body_block.call
        else
          json.set!(name_for_key) do
            body_block.call
          end
        end
      end

      private

      def checked?(value)
        value.to_s == @tag_value.to_s
      end
    end
  end
end
