# frozen_string_literal: true

require "action_view/helpers/tags/collection_helpers"

module FormProps
  module Inputs
    class CollectionRadioButtons < Base
      include ActionView::Helpers::Tags::CollectionHelpers
      include CollectionHelpers

      class RadioButtonBuilder < Builder
        def render(extra_html_options = {})
          html_options = extra_html_options.merge(@input_html_options)
          html_options[:skip_default_ids] = false

          checkbox = RadioButton.new(@object_name, @method_name, @template_object, @value, html_options)
          checkbox.render(true)
          checkbox.json.label @text
        end
      end

      def render
        json.set!(sanitized_key) do
          json.collection do
            render_collection_for(RadioButtonBuilder)
          end

          json.include_hidden(@options.fetch(:include_hidden) { true })

          input_props(@html_options)
        end
      end
    end
  end
end
