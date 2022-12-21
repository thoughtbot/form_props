require_relative "../test_helper"

class SearchFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_search_field
    form_props(model: @post) do |f|
      f.search_field(:title)
    end
    result = json.result!.strip
    expected = {
      "type" => "search",
      "defaultValue" => "Hello World",
      "name" => "post[title]",
      "id" => "post_title"
    }
    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_search_field_with_onsearch_value
    form_props(model: @post) do |f|
      f.search_field(:title, onsearch: true)
    end
    result = json.result!.strip
    expected = {
      "onsearch" => true,
      "incremental" => true,
      "type" => "search",
      "defaultValue" => "Hello World",
      "name" => "post[title]",
      "id" => "post_title"
    }
    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end
end
