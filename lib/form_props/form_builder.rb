# frozen_string_literal: true

module FormProps
  class FormBuilder < ActionView::Helpers::FormBuilder
    undef_method :button,
      :label,
      :datetime_select,
      :time_select,
      :date_select
    # :rich_text_area

    def initialize(*args)
      super
      options = args.last || {}
      @default_options[:controlled] = options[:controlled]
      @default_html_options = @default_html_options.except(:controlled)
    end

    def file_field(method, options = {})
      Inputs::FileField.new(
        @object_name,
        method,
        @template,
        @template.send(:convert_direct_upload_option_to_url, objectify_options(options).dup)
      ).render
    end

    def select(method, choices = [], options = {}, html_options = {})
      Inputs::Select.new(@object_name, method, @template, choices, objectify_options(options), @default_html_options.merge(html_options)).render
    end

    def hidden_field(method, options = {})
      Inputs::HiddenField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def text_field(method, options = {})
      Inputs::TextField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def date_field(method, options = {})
      Inputs::DateField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def time_field(method, options = {})
      Inputs::TimeField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def week_field(method, options = {})
      Inputs::WeekField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def month_field(method, options = {})
      Inputs::MonthField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def datetime_field(method, options = {})
      Inputs::DatetimeLocalField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def datetime_local_field(method, options = {})
      Inputs::DatetimeLocalField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def url_field(method, options = {})
      Inputs::UrlField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def tel_field(method, options = {})
      Inputs::TelField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def color_field(method, options = {})
      Inputs::ColorField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def password_field(method, options = {})
      Inputs::PasswordField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def number_field(method, options = {})
      Inputs::NumberField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def range_field(method, options = {})
      Inputs::RangeField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def email_field(method, options = {})
      Inputs::EmailField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def search_field(method, options = {})
      Inputs::SearchField.new(@object_name, method, @template, objectify_options(options)).render
    end

    def text_area(method, options = {})
      Inputs::TextArea.new(@object_name, method, @template, objectify_options(options)).render
    end

    def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
      Inputs::CheckBox.new(@object_name, method, @template, checked_value, unchecked_value, objectify_options(options)).render
    end

    def radio_button(method, tag_value, options = {})
      Inputs::RadioButton.new(@object_name, method, @template, tag_value, options).render
    end

    def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
      Inputs::CollectionSelect.new(@object_name, method, @template, collection, value_method, text_method, objectify_options(options), @default_html_options.merge(html_options)).render
    end

    def collection_check_boxes(method, collection, value_method, text_method, options = {}, html_options = {}, &block)
      Inputs::CollectionCheckBoxes.new(@object_name, method, @template, collection, value_method, text_method, objectify_options(options), @default_html_options.merge(html_options), &block).render
    end

    def collection_radio_buttons(method, collection, value_method, text_method, options = {}, html_options = {}, &block)
      Inputs::CollectionRadioButtons.new(@object_name, method, @template, collection, value_method, text_method, objectify_options(options), @default_html_options.merge(html_options), &block).render
    end

    def grouped_collection_select(method, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, html_options = {})
      Inputs::GroupedCollectionSelect.new(@object_name, method, @template, collection, group_method, group_label_method, option_key_method, option_value_method, objectify_options(options), @default_html_options.merge(html_options)).render
    end

    def time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
      Inputs::TimeZoneSelect.new(@object_name, method, @template, priority_zones, objectify_options(options), @default_html_options.merge(html_options)).render
    end

    def weekday_select(method, options = {}, html_options = {})
      Inputs::WeekdaySelect.new(@object_name, method, @template, objectify_options(options), @default_html_options.merge(html_options)).render
    end

    def submit(value = nil, options = {})
      value, options = nil, value if value.is_a?(Hash)
      value ||= submit_default_value
      options = {name: "commit", text: value}.update(options)

      Inputs::Submit.new(@template, options).render
    end

    def fields_for_with_nested_attributes(association_name, association, options, block)
      name = "#{object_name}[#{association_name}_attributes]"
      association = convert_to_model(association)
      json = @template.instance_variable_get(:@__json)

      if association.respond_to?(:persisted?)
        association = [association] if @object.public_send(association_name).respond_to?(:to_ary)
      elsif !association.respond_to?(:to_ary)
        association = @object.public_send(association_name)
      end

      if association.respond_to?(:to_ary)
        explicit_child_index = options[:child_index]

        json.set!("#{association_name}_attributes") do
          json.array! association do |child|
            if explicit_child_index
              options[:child_index] = explicit_child_index.call if explicit_child_index.respond_to?(:call)
            else
              options[:child_index] = nested_child_index(name)
            end

            fields_for_nested_model("#{name}[#{options[:child_index]}]", child, options, block)
          end
        end
      elsif association
        json.set!("#{association_name}_attributes") do
          fields_for_nested_model(name, association, options, block)
        end
      end
    end

    def fields_for_nested_model(name, object, fields_options, block)
      object = convert_to_model(object)
      emit_hidden_id = object.persisted? && fields_options.fetch(:include_id) {
        options.fetch(:include_id, true)
      }

      @template.fields_for(name, object, fields_options) do |f|
        block.call(f)
        f.hidden_field(:id) if emit_hidden_id && !f.emitted_hidden_id?
      end
    end

    def fields_for(record_name, record_object = nil, fields_options = {}, &block)
      fields_options, record_object = record_object, nil if record_object.is_a?(Hash) && record_object.extractable_options?
      fields_options[:builder] ||= self.class
      fields_options[:namespace] = options[:namespace]
      fields_options[:parent_builder] = self

      case record_name
      when String, Symbol
        if nested_attributes_association?(record_name)
          return fields_for_with_nested_attributes(record_name, record_object, fields_options, block)
        end
      else
        record_object = record_name.is_a?(Array) ? record_name.last : record_name
        record_name = model_name_from_record_or_class(record_object).param_key
      end

      object_name = @object_name
      index = if options.has_key?(:index)
        options[:index]
      elsif defined?(@auto_index)
        object_name = object_name.to_s.delete_suffix("[]")
        @auto_index
      end

      record_name = if index
        "#{object_name}[#{index}][#{record_name}]"
      elsif record_name.end_with?("[]")
        "#{object_name}[#{record_name[0..-3]}][#{record_object.id}]"
      else
        "#{object_name}[#{record_name}]"
      end
      fields_options[:child_index] = index

      @template.fields_for(record_name, record_object, fields_options, &block)
    end

    def default_form_builder_class
      self.class
    end
  end
end
