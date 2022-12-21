require_relative "../test_helper"

class RadioButtonTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_radio_button
    @post.title = "Hello World"
    form_props(model: @post) do |f|
      f.radio_button(:title, "Hello World")
    end
    result = json.result!.strip
    expected = {
      "type" => "radio",
      "defaultValue" => "Hello World",
      "defaultChecked" => true,
      "name" => "post[title]",
      "id" => "post_title_hello_world"
    }
    assert_equal(JSON.parse(result)["inputs"]["titleHelloWorld"], expected)

    form_props(model: @post) do |f|
      f.radio_button(:title, "Goodbye World")
    end
    result = json.result!.strip
    expected = {
      "type" => "radio",
      "defaultValue" => "Goodbye World",
      "name" => "post[title]",
      "id" => "post_title_goodbye_world"
    }
    assert_equal(JSON.parse(result)["inputs"]["titleGoodbyeWorld"], expected)
  end

  def test_radio_button_is_checked_with_integers
    @post.admin = 1
    form_props(model: @post) do |f|
      f.radio_button(:admin, "1")
    end
    result = json.result!.strip
    expected = {
      "type" => "radio",
      "defaultValue" => "1",
      "defaultChecked" => true,
      "name" => "post[admin]",
      "id" => "post_admin_1"
    }
    assert_equal(JSON.parse(result)["inputs"]["admin1"], expected)
  end

  def test_radio_button_with_negative_integer_value
    @post.admin = -1
    form_props(model: @post) do |f|
      f.radio_button(:admin, "-1")
    end
    result = json.result!.strip
    expected = {
      "type" => "radio",
      "defaultValue" => "-1",
      "defaultChecked" => true,
      "name" => "post[admin]",
      "id" => "post_admin_-1"
    }
    assert_equal(JSON.parse(result)["inputs"]["admin-1"], expected)
  end

  def test_radio_button_respects_passed_in_id
    @post.admin = 1
    form_props(model: @post) do |f|
      f.radio_button(:admin, "1", id: "foo")
    end
    result = json.result!.strip
    expected = {
      "type" => "radio",
      "defaultValue" => "1",
      "defaultChecked" => true,
      "name" => "post[admin]",
      "id" => "foo"
    }
    assert_equal(JSON.parse(result)["inputs"]["admin1"], expected)
  end

  def test_radio_button_with_booleans
    @post.admin = false
    form_props(model: @post) do |f|
      f.radio_button(:admin, true)
    end
    result = json.result!.strip
    expected = {
      "type" => "radio",
      "defaultValue" => "true",
      "name" => "post[admin]",
      "id" => "post_admin_true"
    }
    assert_equal(JSON.parse(result)["inputs"]["adminTrue"], expected)

    @post.admin = true
    form_props(model: @post) do |f|
      f.radio_button(:admin, false)
    end
    result = json.result!.strip
    expected = {
      "type" => "radio",
      "defaultValue" => "false",
      "name" => "post[admin]",
      "id" => "post_admin_false"
    }
    assert_equal(JSON.parse(result)["inputs"]["adminFalse"], expected)
  end
end
