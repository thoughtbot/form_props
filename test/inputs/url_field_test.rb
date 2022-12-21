require_relative "../test_helper"

class UrlFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_url_field
    @post.title = "http://example.com"
    form_props(model: @post) do |f|
      f.url_field(:title)
    end

    result = json.result!.strip
    expected = {
      "type" => "url",
      "defaultValue" => "http://example.com",
      "name" => "post[title]",
      "id" => "post_title"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end
end
