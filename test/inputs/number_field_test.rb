require_relative "../test_helper"

class NumberFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_number_field
    @post.favs = 2
    form_props(model: @post) do |f|
      f.number_field(:favs, in: 1...10)
    end

    result = json.result!.strip
    expected = {
      "type" => "number",
      "defaultValue" => "2",
      "name" => "post[favs]",
      "min" => 1,
      "max" => 9,
      "id" => "post_favs"
    }

    assert_equal(JSON.parse(result)["inputs"]["favs"], expected)

    form_props(model: @post) do |f|
      f.number_field(:favs, size: 30, in: 1...10)
    end

    result = json.result!.strip
    expected = {
      "type" => "number",
      "defaultValue" => "2",
      "size" => 30,
      "name" => "post[favs]",
      "min" => 1,
      "max" => 9,
      "id" => "post_favs"
    }

    assert_equal(JSON.parse(result)["inputs"]["favs"], expected)
  end
end
