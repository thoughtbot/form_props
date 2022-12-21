require_relative "../test_helper"

class PasswordFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_password_field
    @post.title = "does not show"
    form_props(model: @post) do |f|
      f.password_field(:title)
    end

    result = json.result!.strip
    expected = {
      "type" => "password",
      "name" => "post[title]",
      "id" => "post_title"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)

    form_props(model: @post) do |f|
      f.password_field(:title, value: "shows")
    end

    result = json.result!.strip
    expected = {
      "type" => "password",
      "name" => "post[title]",
      "id" => "post_title",
      "defaultValue" => "shows"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end
end
