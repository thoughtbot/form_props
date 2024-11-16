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
        @key = options.delete(:key)

        super(object_name, method_name, template_object, options)
      end

      private

      def sanitized_key
        @key || sanitized_method_name.camelize(:lower)
      end

      def input_props(options)
        return if options.blank?
        # tag_type = options[:type]

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

        is_checkable = respond_to?(:field_type, true) && (field_type == "checkbox" || field_type == "radio")

        @controlled ||= nil

        if !@controlled
          if key.to_sym == :value && !is_checkable
            key = "default_value"
          end

          if key.to_sym == :checked
            key = "default_checked"
          end
        end

        key = FormProps::Helper.format_key(key)
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
    end
  end
end
