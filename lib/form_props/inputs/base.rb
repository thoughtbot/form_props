# frozen_string_literal: true

module FormProps
  module Inputs
    class Base < ::ActionView::Helpers::Tags::Base
      def json
        @json ||= @template_object.instance_variable_get(:@__json)
      end

      def initialize(object_name, method_name, template_object, options = {})
        options = options.with_indifferent_access

        @controlled = options.delete(:controlled)
        super(object_name, method_name, template_object, options)
      end

      private

      def add_options(option_tags, options, value = nil)
        if options[:include_blank]
          content = (options[:include_blank] if options[:include_blank].is_a?(String))
          label = (" " unless content)
          option_tags = [{label: content || label, value: ""}] + option_tags
        end

        if value.blank? && options[:prompt]
          tag_options = {value: ""}.tap do |prompt_opts|
            prompt_opts[:disabled] = true if options[:disabled] == ""
            if options[:selected] == ""
              selected_values.push("")
            end
            prompt_opts[:label] = prompt_text(options[:prompt])
          end
          option_tags = [tag_options] + option_tags
        end

        option_tags
      end

      def input_props(options)
        return if options.blank?

        options.each_pair do |key, value|
          type = TAG_TYPES[key]

          if type == :data && value.is_a?(Hash)
            value.each_pair do |k, v|
              next if v.nil?
              prefix_tag_props(key, k, v)
            end
          elsif type == :aria && value.is_a?(Hash)
            value.each_pair do |k, v|
              next if v.nil?

              case v
              when Array, Hash
                tokens = build_values(v)
                next if tokens.none?

                v = safe_join(tokens, " ")
              else
                v = v.to_s
              end

              prefix_tag_props(key, k, v)
            end
          elsif key == "class" || key == :class
            value = build_values(value).join(" ")
            key = "class_name"
            tag_option(key, value)
          elsif !value.nil?
            if key.to_s == "value"
              key = key.to_s
              value = value.is_a?(Array) ? value : value.to_s
            end
            tag_option(key, value)
          end
        end
      end

      def tag_option(key, value)
        if value.is_a? Regexp
          value = value.source
        end

        @controlled ||= nil

        if !@controlled
          if key.to_sym == :value
            key = "default_value"
          end

          if key.to_sym == :checked
            key = "default_checked"
          end
        end

        json.set!(key, value)
      end

      def prefix_tag_props(prefix, key, value)
        key = "#{prefix}-#{key.to_s.dasherize}"
        unless value.is_a?(String) || value.is_a?(Symbol) || value.is_a?(BigDecimal)
          value = value.to_json
        end
        tag_option(key, value)
      end

      def build_values(*args)
        tag_values = []

        args.each do |tag_value|
          case tag_value
          when Hash
            tag_value.each do |key, val|
              tag_values << key.to_s if val && key.present?
            end
          when Array
            tag_values.concat build_values(*tag_value)
          else
            tag_values << tag_value.to_s if tag_value.present?
          end
        end

        tag_values
      end

      def select_content_props(option_tags, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)

        if placeholder_required?(html_options)
          raise ArgumentError, "include_blank cannot be false for a required field." if options[:include_blank] == false
          options[:include_blank] ||= true unless options[:prompt]
        end

        html_options["type"] = "select"
        value_for_blank = options.fetch(:selected) { value }
        option_tags = add_options(option_tags, options, value_for_blank)

        if options[:multiple]
          html_options["multiple"] = options[:multiple]
        end

        if selected_values.any?
          html_options["value"] ||= if html_options["multiple"]
            Array(selected_values)
          else
            selected_values.first
          end
        end

        json.set!(sanitized_method_name) do
          input_props(html_options)

          if options.key?(:include_hidden)
            json.include_hidden options[:include_hidden]
          end
          json.options(option_tags)
        end
      end
    end
  end
end
