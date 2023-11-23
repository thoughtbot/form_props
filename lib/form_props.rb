# frozen_string_literal: true

require "action_view"
require "action_pack"
require "form_props/helper"
require "form_props/action_view_extensions/form_helper"
require "form_props/form_options_helper"
require "form_props/inputs/base"
require "form_props/inputs/text_field"
require "form_props/inputs/text_area"
require "form_props/inputs/check_box"
require "form_props/inputs/select"
require "form_props/inputs/collection_helpers"
require "form_props/inputs/collection_select"
require "form_props/inputs/grouped_collection_select"
require "form_props/inputs/collection_check_boxes"
require "form_props/inputs/collection_radio_buttons"
require "form_props/inputs/search_field"
require "form_props/inputs/radio_button"
require "form_props/inputs/url_field"
require "form_props/inputs/email_field"
require "form_props/inputs/number_field"
require "form_props/inputs/range_field"
require "form_props/inputs/tel_field"
require "form_props/inputs/color_field"
require "form_props/inputs/password_field"
require "form_props/inputs/datetime_field"
require "form_props/inputs/datetime_local_field"
require "form_props/inputs/date_field"
require "form_props/inputs/time_field"
require "form_props/inputs/file_field"
require "form_props/inputs/week_field"
require "form_props/inputs/month_field"
require "form_props/inputs/hidden_field"
require "form_props/inputs/time_zone_select"
require "form_props/inputs/weekday_select"
require "form_props/inputs/submit"
require "form_props/form_builder"

module FormProps
  extend ActiveSupport::Autoload

  def self.set(json, template)
    template.instance_variable_set(:@__json, json)
  end
end
