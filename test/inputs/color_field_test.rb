require_relative "../test_helper"

class ColorFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_color_field_with_valid_hex_color_string
    @post.title = "#000fff"
    form_props(model: @post) do |f|
      f.color_field(:title)
    end

    result = json.result!.strip
    expected = {
      "type" => "color",
      "defaultValue" => "#000fff",
      "name" => "post[title]",
      "id" => "post_title"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_color_field_with_invalid_hex_color_string
    @post.title = "#1234TR"
    form_props(model: @post) do |f|
      f.color_field(:title)
    end

    result = json.result!.strip
    expected = {
      "type" => "color",
      "defaultValue" => "#000000",
      "name" => "post[title]",
      "id" => "post_title"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_color_field_with_value_attr
    @post.title = "#1234TR"
    form_props(model: @post) do |f|
      f.color_field(:title, value: "#00FF00")
    end

    result = json.result!.strip
    expected = {
      "type" => "color",
      "defaultValue" => "#00FF00",
      "name" => "post[title]",
      "id" => "post_title"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end
end
