# frozen_string_literal: true

module FormProps
  module ActionViewExtensions
    module FormHelper
      def form_props(model: nil, scope: nil, url: nil, format: nil, **options, &block)
        json = @__json

        options = {
          allow_method_names_outside_object: true,
          controlled: false
        }.merge!(options)

        options.delete(:remote)

        options[:local] = true
        options[:skip_default_ids] = false

        if model
          if url != false
            url ||= if format.nil?
              polymorphic_path(model, {})
            else
              polymorphic_path(model, format: format)
            end
          end

          model = convert_to_model(_object_for_form_builder(model))
          scope ||= model_name_from_record_or_class(model).param_key
        end

        if block
          options[:builder] = FormProps::FormBuilder

          builder = instantiate_builder(scope, model, options)
          json.inputs do
            capture(builder, &block)
          end
          options[:multipart] ||= builder.multipart?
        end

        html_options = html_options_for_form_with(url, model, **options)

        json.extras do
          extra_props_for_form(json, html_options)
        end

        json.form(FormProps::Helper.format_keys(html_options))
      end

      private

      def token_props(json, token = nil, form_options: {})
        if token != false && defined?(protect_against_forgery?) && protect_against_forgery?
          token =
            if token == true || token.nil?
              form_authenticity_token(form_options: form_options.merge(authenticity_token: token))
            else
              token
            end

          json.set!("csrf") do
            json.name request_forgery_protection_token.to_s
            json.type "hidden"
            json.defaultValue token
            json.autoComplete "off"
          end
        end
      end

      def method_props(json, method)
        json.set!("method") do
          json.name "_method"
          json.type "hidden"
          json.defaultValue method.to_s
          json.autoComplete "off"
        end
      end

      def utf8_enforcer_props(json)
        json.set!("utf8") do
          json.name "utf8"
          json.type "hidden"
          json.defaultValue "&#x2713;"
          json.autoComplete "off"
        end
      end

      def extra_props_for_form(json, html_options)
        authenticity_token = html_options.delete("authenticity_token")
        method = html_options.delete("method").to_s.downcase

        case method
        when "get"
          html_options["method"] = "get"
        when "post", ""
          html_options["method"] = "post"
          token_props(json, authenticity_token, form_options: {
            action: html_options["action"],
            method: "post"
          })
        else
          html_options["method"] = "post"
          method_props(json, method)
          token_props(json, authenticity_token, form_options: {
            action: html_options["action"],
            method: method
          })
        end

        if html_options.delete("enforce_utf8") { default_enforce_utf8 }
          utf8_enforcer_props(json)
        end
      end
    end
  end
end

ActiveSupport.on_load(:action_view) do
  include FormProps::ActionViewExtensions::FormHelper
end
