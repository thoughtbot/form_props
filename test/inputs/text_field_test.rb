require_relative "../test_helper"

class TextFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_text_field_placeholder_without_locales
    @post = Post.new
    @post.body = "Back to the hill and over it again!"

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_field(:body, placeholder: true)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[body]",
      "placeholder" => "Body",
      "id" => "post_body",
      "defaultValue" => "Back to the hill and over it again!"
    }

    assert_equal(JSON.parse(result)["inputs"]["body"], expected)
  end

  def test_text_field_placeholder_with_locales
    @post = Post.new
    @post.title = "Hello World"

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_field(:title, placeholder: true)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[title]",
      "placeholder" => "What is this about?",
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_field_placeholder_with_human_attribute_name
    @post = Post.new

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_field(:cost, placeholder: true)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[cost]",
      "placeholder" => "Total cost",
      "id" => "post_cost"
    }

    assert_equal(JSON.parse(result)["inputs"]["cost"], expected)
  end

  def test_text_field_placeholder_with_string_value
    @post = Post.new

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_field(:cost, placeholder: "HOW MUCH?")
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[cost]",
      "placeholder" => "HOW MUCH?",
      "id" => "post_cost"
    }

    assert_equal(JSON.parse(result)["inputs"]["cost"], expected)
  end

  def test_text_field_placeholder_with_human_attribute_name_and_value
    @post = Post.new

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_field(:cost, placeholder: :uk)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[cost]",
      "placeholder" => "Pounds",
      "id" => "post_cost"
    }

    assert_equal(JSON.parse(result)["inputs"]["cost"], expected)
  end

  def test_text_field_placeholder_with_locales_and_value
    @post = Post.new

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_field(:written_on, placeholder: :spanish)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[written_on]",
      "placeholder" => "Escrito en",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_text_field_placeholder_with_locales_and_nested_attributes
    I18n.with_locale :placeholder do
      form_props(model: @post, method: :patch) do |f|
        f.fields_for(:comments) do |cf|
          cf.text_field(:body, placeholder: true)
        end
      end
    end
    result = json.result!.strip

    expected = {
      "inputs" => {
        "commentsAttributes" => [
          {
            "body" => {
              "placeholder" => "Write body here",
              "type" => "text",
              "name" => "post[comments_attributes][0][body]",
              "id" => "post_comments_attributes_0_body"
            }
          }
        ]
      },
      "extras" => {
        "utf8" => {"name" => "utf8", "type" => "hidden", "defaultValue" => "&#x2713;", "autoComplete" => "off"},
        "method" => {"name" => "_method", "type" => "hidden", "defaultValue" => "patch", "autoComplete" => "off"}
      },
      "form" => {"action" => "/posts/123", "acceptCharset" => "UTF-8", "method" => "post"}
    }

    assert_equal(JSON.parse(result), expected)
  end

  def test_text_field_placeholder_with_locales_fallback_and_nested_attributes
    I18n.with_locale :placeholder do
      form_props(model: @post, method: :patch) do |f|
        f.fields_for(:tags) do |cf|
          cf.text_field(:value, placeholder: true)
        end
      end
    end
    result = json.result!.strip

    expected = {
      "inputs" => {
        "tagsAttributes" => [
          {
            "value" => {
              "placeholder" => "Tag",
              "type" => "text",
              "defaultValue" => "new tag",
              "name" => "post[tags_attributes][0][value]",
              "id" => "post_tags_attributes_0_value"
            }
          }
        ]
      },
      "extras" => {
        "utf8" => {"name" => "utf8", "type" => "hidden", "defaultValue" => "&#x2713;", "autoComplete" => "off"},
        "method" => {"name" => "_method", "type" => "hidden", "defaultValue" => "patch", "autoComplete" => "off"}
      },
      "form" => {"action" => "/posts/123", "acceptCharset" => "UTF-8", "method" => "post"}
    }

    assert_equal(JSON.parse(result), expected)
  end

  def test_text_field
    form_props(model: @post) do |f|
      f.text_field(:title)
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[title]",
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_field_with_options
    form_props(model: @post) do |f|
      f.text_field(:title, size: 35)
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[title]",
      "size" => 35,
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)

    form_props(model: @post) do |f|
      f.text_field(:title, "size" => 35)
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[title]",
      "size" => 35,
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_field_assuming_size
    form_props(model: @post) do |f|
      f.text_field(:title, max_length: 35)
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[title]",
      "maxLength" => 35,
      "size" => 35,
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)

    form_props(model: @post) do |f|
      f.text_field(:title, "max_length" => 35)
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[title]",
      "maxLength" => 35,
      "size" => 35,
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_field_removing_size
    form_props(model: @post) do |f|
      f.text_field(:title, max_length: 35, size: nil)
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[title]",
      "maxLength" => 35,
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)

    form_props(model: @post) do |f|
      f.text_field(:title, "max_length" => 35, "size" => nil)
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[title]",
      "maxLength" => 35,
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_field_with_nil_value
    form_props(model: @post) do |f|
      f.text_field(:title, value: nil)
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[title]",
      "id" => "post_title"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_field_with_nil_name
    form_props(model: @post) do |f|
      f.text_field(:title, name: nil)
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_field_tag
    form_props(model: @post) do |f|
      f.text_field(:title, value: "Hello")
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "id" => "post_title",
      "name" => "post[title]",
      "defaultValue" => "Hello"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_field_tag_class_string
    form_props(model: @post) do |f|
      f.text_field(:title, value: "Hello", class_name: "admin")
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "id" => "post_title",
      "name" => "post[title]",
      "className" => "admin",
      "defaultValue" => "Hello"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_field_tag_with_ac_parameters
    form_props(model: @post) do |f|
      f.text_field(:title, value: ActionController::Parameters.new(key: "value"))
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "id" => "post_title",
      "name" => "post[title]",
      "defaultValue" => "{\"key\"=>\"value\"}"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_field_tag_disabled
    form_props(model: @post) do |f|
      f.text_field(:title, value: "Hello!", disabled: true)
    end
    result = json.result!.strip

    expected = {
      "type" => "text",
      "id" => "post_title",
      "name" => "post[title]",
      "disabled" => true,
      "defaultValue" => "Hello!"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end
end
