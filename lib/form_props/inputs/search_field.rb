# frozen_string_literal: true

module FormProps
  module Inputs
    class SearchField < FormProps::Inputs::TextField
      def render
        if @options[:autosave]
          if @options[:autosave] == true
            @options[:autosave] = request.host.split(".").reverse.join(".")
          end
          @options[:results] ||= 10
        end

        if @options[:onsearch]
          @options[:incremental] = true unless @options.has_key?(:incremental)
        end

        super
      end

      private

      def field_type
        "search"
      end
    end
  end
end
