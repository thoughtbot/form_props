module FormProps
  module SelectRenderer
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

      json.set!(sanitized_key) do
        input_props(html_options)

        if options.key?(:include_hidden)
          json.includeHidden options[:include_hidden]
        end
        json.options(option_tags)
      end
    end
  end
end
