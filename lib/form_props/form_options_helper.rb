# frozen_string_literal: true

module FormProps
  module FormOptionsHelper
    def selected_values
      @selected_values ||= []
      @selected_values
    end

    def grouped_options_for_select(grouped_options, selected_key = nil, options = {})
      prompt = options[:prompt]
      divider = options[:divider]

      options = []

      if prompt
        options.push({
          label: prompt_text(prompt),
          value: ""
        })
      end

      grouped_options.each do |container|
        html_attributes = option_html_attributes(container)

        if divider
          label = divider
        else
          label, container = container
        end

        options.push({label: label, options: options_for_select(container, selected_key)}
          .merge!(html_attributes))
      end

      options
    end

    def option_html_attributes(element)
      if Array === element
        element.select { |e| Hash === e }.reduce({}, :merge!)
      else
        {}
      end
    end

    def options_for_select(container, selected = nil)
      selected, disabled = extract_selected_and_disabled(selected).map do |r|
        Array(r).map(&:to_s)
      end

      container.map do |element|
        html_attributes = option_html_attributes(element)
        text, value = option_text_and_value(element).map(&:to_s)

        if !html_attributes[:selected] && option_value_selected?(value, selected)
          selected_values.push(value)
        end

        if html_attributes[:selected]
          selected_values.push(value)
        end

        if !html_attributes[:disabled] && (disabled && option_value_selected?(value, disabled))
          html_attributes[:disabled] = true
        end

        html_attributes[:value] = value
        html_attributes[:label] = text

        html_attributes
      end
    end

    def option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method, selected_key = nil)
      collection.map do |group|
        option_tags = options_from_collection_for_select(
          value_for_collection(group, group_method),
          option_key_method,
          option_value_method,
          selected_key
        )

        {
          options: option_tags,
          label: value_for_collection(group, group_label_method)
        }
      end
    end

    def options_from_collection_for_select(collection, value_method, text_method, selected = nil)
      options = collection.map do |element|
        [value_for_collection(element, text_method), value_for_collection(element, value_method), option_html_attributes(element)]
      end
      selected, disabled = extract_selected_and_disabled(selected)
      select_deselect = {
        selected: extract_values_from_collection(collection, value_method, selected),
        disabled: extract_values_from_collection(collection, value_method, disabled)
      }

      options_for_select(options, select_deselect)
    end

    def value_for_collection(item, value)
      value.respond_to?(:call) ? value.call(item) : item.public_send(value)
    end

    def extract_selected_and_disabled(selected)
      if selected.is_a?(Proc)
        [selected, nil]
      else
        selected = Array.wrap(selected)
        options = selected.extract_options!.symbolize_keys
        selected_items = options.fetch(:selected, selected)
        [selected_items, options[:disabled]]
      end
    end

    def extract_values_from_collection(collection, value_method, selected)
      if selected.is_a?(Proc)
        collection.map do |element|
          element.public_send(value_method) if selected.call(element)
        end.compact
      else
        selected
      end
    end

    def time_zone_options_for_select(selected = nil, priority_zones = nil, model = ::ActiveSupport::TimeZone)
      zone_options = []

      zones = model.all
      convert_zones = lambda { |list| list.map { |z| [z.to_s, z.name] } }

      if priority_zones
        if priority_zones.is_a?(Regexp)
          priority_zones = zones.select { |z| z.match?(priority_zones) }
        end

        zone_options.concat(options_for_select(convert_zones[priority_zones], selected))
        zone_options.push({label: "-------------", value: "", disabled: true})

        zones -= priority_zones
      end

      zone_options.concat(options_for_select(convert_zones[zones], selected))
      zone_options
    end

    def weekday_options_for_select(selected = nil, index_as_value: false, day_format: :day_names, beginning_of_week: Date.beginning_of_week)
      day_names = I18n.translate("date.#{day_format}")
      day_names = day_names.map.with_index.to_a if index_as_value
      day_names = day_names.rotate(Date::DAYS_INTO_WEEK.fetch(beginning_of_week))

      options_for_select(day_names, selected)
    end
  end
end
