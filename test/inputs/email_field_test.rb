require_relative "../test_helper"

class EmailFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_url_field
    @post.title = "james@smith.com"
    form_props(model: @post) do |f|
      f.email_field(:title)
    end

    result = json.result!.strip
    expected = {
      "type" => "email",
      "defaultValue" => "james@smith.com",
      "name" => "post[title]",
      "id" => "post_title"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end
end
