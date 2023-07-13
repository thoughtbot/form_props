require_relative "../test_helper"

class CheckboxFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_check_box
    @post.admin = false
    form_props(model: @post) do |f|
      f.check_box(:admin)
    end
    result = json.result!.strip
    expected = {
      "type" => "checkbox",
      "defaultValue" => "1",
      "uncheckedValue" => "0",
      "includeHidden" => true,
      "name" => "post[admin]",
      "id" => "post_admin"
    }
    assert_equal(JSON.parse(result)["inputs"]["admin"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <CheckBox {...formProps["inputs"]["admin"]}/>
    JS

    assert_dom_equal(
      '<input name="post[admin]" type="hidden" value="0" autocomplete="off" /><input id="post_admin" name="post[admin]" type="checkbox" value="1" />',
      output
    )
    @post.admin = true
  end

  def test_check_box_disabled
    @post.admin = false
    form_props(model: @post) do |f|
      f.check_box(:admin, disabled: true)
    end
    result = json.result!.strip
    expected = {
      "type" => "checkbox",
      "defaultValue" => "1",
      "uncheckedValue" => "0",
      "disabled" => true,
      "includeHidden" => true,
      "name" => "post[admin]",
      "id" => "post_admin"
    }
    assert_equal(JSON.parse(result)["inputs"]["admin"], expected)
    @post.admin = true
  end

  def test_check_box_default_checked
    @post.admin = true
    form_props(model: @post) do |f|
      f.check_box(:admin)
    end
    result = json.result!.strip
    expected = {
      "type" => "checkbox",
      "defaultValue" => "1",
      "uncheckedValue" => "0",
      "defaultChecked" => true,
      "includeHidden" => true,
      "name" => "post[admin]",
      "id" => "post_admin"
    }
    assert_equal(JSON.parse(result)["inputs"]["admin"], expected)
    @post.admin = true
  end

  def test_check_box_checked_if_object_value_is_same_that_check_value
    form_props(model: @post) do |f|
      f.check_box(:secret)
    end
    result = json.result!.strip
    expected = {
      "type" => "checkbox",
      "defaultValue" => "1",
      "defaultChecked" => true,
      "uncheckedValue" => "0",
      "includeHidden" => true,
      "name" => "post[secret]",
      "id" => "post_secret"
    }
    assert_equal(JSON.parse(result)["inputs"]["secret"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <CheckBox {...formProps["inputs"]["secret"]}/>
    JS

    assert_dom_equal(
      '<input name="post[secret]" type="hidden" value="0" autocomplete="off" /><input checked="" id="post_secret" name="post[secret]" type="checkbox" value="1" />',
      output
    )
  end

  def test_check_box_not_checked_if_object_value_is_same_that_unchecked_value
    @post.secret = 0
    form_props(model: @post) do |f|
      f.check_box(:secret)
    end
    result = json.result!.strip
    expected = {
      "type" => "checkbox",
      "defaultValue" => "1",
      "uncheckedValue" => "0",
      "includeHidden" => true,
      "name" => "post[secret]",
      "id" => "post_secret"
    }
    assert_equal(JSON.parse(result)["inputs"]["secret"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <CheckBox {...formProps["inputs"]["secret"]}/>
    JS

    assert_dom_equal(
      '<input name="post[secret]" type="hidden" value="0" autocomplete="off" /><input id="post_secret" name="post[secret]" type="checkbox" value="1" />',
      output
    )
  end

  def test_check_box_checked_if_option_checked_is_present
    @post.admin = false
    form_props(model: @post) do |f|
      f.check_box(:admin, checked: "checked")
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultChecked"], true)
    @post.admin = true
  end

  def test_check_box_checked_if_object_value_is_true
    @post.admin = true
    form_props(model: @post) do |f|
      f.check_box(:admin)
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultChecked"], true)

    @post.instance_eval do
      def secret?
        true
      end
    end

    form_props(model: @post) do |f|
      f.check_box(:secret)
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["secret"]["defaultChecked"], true)
    @post.admin = true
  end

  def test_check_box_checked_if_object_value_includes_checked_value
    @post.admin = ["0"]
    form_props(model: @post) do |f|
      f.check_box(:admin)
    end
    result = json.result!.strip

    assert_nil(JSON.parse(result)["inputs"]["admin"]["defaultChecked"])
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "1")

    @post.admin = ["1"]
    form_props(model: @post) do |f|
      f.check_box(:admin)
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultChecked"], true)
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "1")

    @post.admin = Set.new(["1"])
    form_props(model: @post) do |f|
      f.check_box(:admin)
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultChecked"], true)
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "1")
  end

  def test_check_box_with_include_hidden_false
    @post.secret = false
    form_props(model: @post) do |f|
      f.check_box(:secret, include_hidden: false)
    end
    result = json.result!.strip
    expected = {
      "type" => "checkbox",
      "defaultValue" => "1",
      "includeHidden" => false,
      "uncheckedValue" => "0",
      "name" => "post[secret]",
      "id" => "post_secret"
    }
    assert_equal(JSON.parse(result)["inputs"]["secret"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <CheckBox {...formProps["inputs"]["secret"]}/>
    JS

    assert_dom_equal(
      '<input id="post_secret" name="post[secret]" type="checkbox" value="1" />',
      output
    )
  end

  def test_check_box_with_explicit_checked_and_unchecked_values_when_object_value_is_string
    @post.admin = "on"
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, "on", "off")
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultChecked"], true)
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "on")

    @post.admin = "off"
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, "on", "off")
    end
    result = json.result!.strip

    assert_nil(JSON.parse(result)["inputs"]["admin"]["defaultChecked"])
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "on")
  end

  def test_check_box_with_explicit_checked_and_unchecked_values_when_object_value_is_boolean
    @post.admin = false
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, false, true)
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultChecked"], true)
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "false")

    @post.admin = true
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, false, true)
    end
    result = json.result!.strip

    assert_nil(JSON.parse(result)["inputs"]["admin"]["defaultChecked"])
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "false")
  end

  def test_check_box_with_explicit_checked_and_unchecked_values_when_object_value_is_integer
    @post.admin = 0
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, 0, 1)
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultChecked"], true)
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "0")

    @post.admin = 1
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, 0, 1)
    end
    result = json.result!.strip

    assert_nil(JSON.parse(result)["inputs"]["admin"]["defaultChecked"])
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "0")

    @post.admin = 2
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, 0, 1)
    end
    result = json.result!.strip

    assert_nil(JSON.parse(result)["inputs"]["admin"]["defaultChecked"])
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "0")
  end

  def test_check_box_with_explicit_checked_and_unchecked_values_when_object_value_is_float
    @post.admin = 0.0
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, 0, 1)
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultChecked"], true)
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "0")

    @post.admin = 1.1
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, 0, 1)
    end
    result = json.result!.strip

    assert_nil(JSON.parse(result)["inputs"]["admin"]["defaultChecked"])
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "0")

    @post.admin = 2.2
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, 0, 1)
    end
    result = json.result!.strip

    assert_nil(JSON.parse(result)["inputs"]["admin"]["defaultChecked"])
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "0")
  end

  def test_check_box_with_explicit_checked_and_unchecked_values_when_object_value_is_big_decimal
    @post.admin = BigDecimal("0")
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, 0, 1)
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultChecked"], true)
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "0")

    @post.admin = BigDecimal("1")
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, 0, 1)
    end
    result = json.result!.strip

    assert_nil(JSON.parse(result)["inputs"]["admin"]["defaultChecked"])
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "0")

    @post.admin = BigDecimal("2.2", 1)
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, 0, 1)
    end
    result = json.result!.strip

    assert_nil(JSON.parse(result)["inputs"]["admin"]["defaultChecked"])
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "0")
  end

  def test_check_box_with_nil_unchecked_value
    @post.admin = "on"
    form_props(model: @post) do |f|
      f.check_box(:admin, {}, "on", nil)
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultChecked"], true)
    assert_equal(JSON.parse(result)["inputs"]["admin"]["defaultValue"], "on")
  end

  def test_check_box_with_multiple_behavior
    @post.comment_ids = [2, 3]

    form_props(model: @post) do |f|
      f.check_box(:comment_ids, {multiple: true}, 1)
    end
    result = json.result!.strip

    expected = {
      "type" => "checkbox",
      "defaultValue" => "1",
      "uncheckedValue" => "0",
      "includeHidden" => true,
      "name" => "post[comment_ids][]",
      "id" => "post_comment_ids_1"
    }

    assert_equal(JSON.parse(result)["inputs"]["commentIds"], expected)

    form_props(model: @post) do |f|
      f.check_box(:comment_ids, {"multiple" => true}, 3)
    end
    result = json.result!.strip

    expected = {
      "type" => "checkbox",
      "defaultValue" => "3",
      "defaultChecked" => true,
      "uncheckedValue" => "0",
      "includeHidden" => true,
      "name" => "post[comment_ids][]",
      "id" => "post_comment_ids_3"
    }

    assert_equal(JSON.parse(result)["inputs"]["commentIds"], expected)
  end

  def test_checkbox_disabled_disables_hidden_field
    @post.admin = true
    form_props(model: @post) do |f|
      f.check_box(:admin, disabled: true)
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["disabled"], true)
  end

  def test_checkbox_form_html5_attribute
    @post.admin = true
    form_props(model: @post) do |f|
      f.check_box(:admin, form: "new_form")
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["admin"]["form"], "new_form")
  end
end
