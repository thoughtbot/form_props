require_relative "../test_helper"

class HiddenFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_hidden_field
    form_props(model: @post) do |f|
      f.hidden_field(:title)
    end

    result = json.result!.strip
    expected = {
      "type" => "hidden",
      "defaultValue" => "Hello World",
      "name" => "post[title]",
      "id" => "post_title",
      "autoComplete" => "off"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)

    form_props(model: @post) do |f|
      f.hidden_field(:secret?)
    end

    result = json.result!.strip
    expected = {
      "type" => "hidden",
      "defaultValue" => "1",
      "name" => "post[secret]",
      "id" => "post_secret",
      "autoComplete" => "off"
    }

    assert_equal(JSON.parse(result)["inputs"]["secret"], expected)
  end

  def test_hidden_field_with_nil_value
    @post.title = nil
    form_props(model: @post) do |f|
      f.hidden_field(:title)
    end

    result = json.result!.strip
    expected = {
      "type" => "hidden",
      "name" => "post[title]",
      "id" => "post_title",
      "autoComplete" => "off"
    }
    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_hidden_field_with_options
    assert_dom_equal(
      '<input id="post_title" name="post[title]" type="hidden" value="Something Else" autoComplete="off" />',
      hidden_field("post", "title", value: "Something Else")
    )
    @post.title = nil
    form_props(model: @post) do |f|
      f.hidden_field(:title, value: "Something Else")
    end

    result = json.result!.strip
    expected = {
      "type" => "hidden",
      "name" => "post[title]",
      "defaultValue" => "Something Else",
      "id" => "post_title",
      "autoComplete" => "off"
    }
    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end
end
