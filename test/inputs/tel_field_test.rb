require_relative "../test_helper"

class TelFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_tel_field
    @post.title = "2125559090"
    form_props(model: @post) do |f|
      f.tel_field(:title)
    end

    result = json.result!.strip
    expected = {
      "type" => "tel",
      "defaultValue" => "2125559090",
      "name" => "post[title]",
      "id" => "post_title"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end
end
