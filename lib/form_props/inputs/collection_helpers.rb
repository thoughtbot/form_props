# frozen_string_literal: true

module FormProps
  module Inputs
    module CollectionHelpers
      def render_collection
        json.array! @collection do |item|
          value = value_for_collection(item, @value_method)
          text = value_for_collection(item, @text_method)
          default_html_options = default_html_options_for_collection(item, value)
          additional_html_options = option_html_attributes(item)

          yield item, value, text, default_html_options.merge(additional_html_options)
        end
      end

      def default_html_options_for_collection(item, value)
        html_options = @html_options.dup

        [:checked, :selected, :disabled, :read_only].each do |option|
          current_value = @options[option]
          next if current_value.nil?

          accept = if current_value.respond_to?(:call)
            current_value.call(item)
          else
            Array(current_value).map(&:to_s).include?(value.to_s)
          end

          if accept
            html_options[option] = true
          elsif option == :checked
            html_options[option] = false
          end
        end

        html_options[:object] = @object
        html_options
      end

      def render_collection_for(builder_class, &block)
        render_collection do |item, value, text, default_html_options|
          builder = instantiate_builder(builder_class, item, value, text, default_html_options)
          builder.render
        end
      end

      def hidden_field_name
        @html_options[:name] || tag_name(false, @options[:index]).to_s
      end
    end
  end
end
