require_relative "../test_helper"

class TextAreaTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_text_area_placeholder_without_locales
    @post = Post.new
    @post.body = "Back to the hill and over it again!"

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_area(:body, placeholder: true)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[body]",
      "placeholder" => "Body",
      "id" => "post_body",
      "defaultValue" => "Back to the hill and over it again!"
    }

    assert_equal(JSON.parse(result)["inputs"]["body"], expected)
  end

  def test_text_area_placeholder_with_locales
    @post = Post.new
    @post.title = "Hello World"

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_area(:title, placeholder: true)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[title]",
      "placeholder" => "What is this about?",
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_area_placeholder_with_human_attribute_name
    @post = Post.new

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_area(:cost, placeholder: true)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[cost]",
      "placeholder" => "Total cost",
      "id" => "post_cost"
    }

    assert_equal(JSON.parse(result)["inputs"]["cost"], expected)
  end

  def test_text_area_placeholder_with_string_value
    @post = Post.new

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_area(:cost, placeholder: "HOW MUCH?")
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[cost]",
      "placeholder" => "HOW MUCH?",
      "id" => "post_cost"
    }

    assert_equal(JSON.parse(result)["inputs"]["cost"], expected)
  end

  def test_text_area_placeholder_with_human_attribute_name_and_value
    @post = Post.new

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_area(:cost, placeholder: :uk)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[cost]",
      "placeholder" => "Pounds",
      "id" => "post_cost"
    }

    assert_equal(JSON.parse(result)["inputs"]["cost"], expected)
  end

  def test_text_area_placeholder_with_locales_and_value
    @post = Post.new

    I18n.with_locale :placeholder do
      form_props(model: @post) do |f|
        f.text_area(:written_on, placeholder: :spanish)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[written_on]",
      "placeholder" => "Escrito en",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_text_area_placeholder_with_locales_and_nested_attributes
    I18n.with_locale :placeholder do
      form_props(model: @post, method: :patch) do |f|
        f.fields_for(:comments) do |cf|
          cf.text_area(:body, placeholder: true)
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
              "type" => "textarea",
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

  def test_text_area_placeholder_with_locales_fallback_and_nested_attributes
    I18n.with_locale :placeholder do
      form_props(model: @post, method: :patch) do |f|
        f.fields_for(:tags) do |cf|
          cf.text_area(:value, placeholder: true)
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
              "type" => "textarea",
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

  def test_text_area
    form_props(model: @post) do |f|
      f.text_area(:title)
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[title]",
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_area_with_escapes
    @post.title = "Back to <i>the</i> hill and over it again!"
    form_props(model: @post) do |f|
      f.text_area(:title)
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[title]",
      "id" => "post_title",
      "defaultValue" => "Back to <i>the</i> hill and over it again!"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_area_with_alternate_value
    form_props(model: @post) do |f|
      f.text_area(:title, value: "Testing alternate values.")
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[title]",
      "id" => "post_title",
      "defaultValue" => "Testing alternate values."
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_area_with_nil_alternate_value
    form_props(model: @post) do |f|
      f.text_area(:title, value: nil)
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[title]",
      "id" => "post_title"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_area_with_size_option
    form_props(model: @post) do |f|
      f.text_area(:title, size: "183x820")
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[title]",
      "cols" => "183",
      "rows" => "820",
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_area_tag_size_string
    form_props(model: @post) do |f|
      f.text_area(:title, "size" => "20x40")
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[title]",
      "cols" => "20",
      "rows" => "40",
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_area_tag_should_disregard_size_if_its_given_as_an_integer
    form_props(model: @post) do |f|
      f.text_area(:title, size: 20)
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[title]",
      "id" => "post_title",
      "defaultValue" => "Hello World"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_area_tag_unescaped_content
    @post.title = "<b>hello world</b>"

    form_props(model: @post) do |f|
      f.text_area(:title, size: "20x40")
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[title]",
      "id" => "post_title",
      "cols" => "20",
      "rows" => "40",
      "defaultValue" => "<b>hello world</b>"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_area_tag_unescaped_nil_content
    form_props(model: @post) do |f|
      f.text_area(:title, value: nil)
    end
    result = json.result!.strip

    expected = {
      "type" => "textarea",
      "name" => "post[title]",
      "id" => "post_title"
    }

    assert_equal(JSON.parse(result)["inputs"]["title"], expected)
  end

  def test_text_area_tag_options_symbolize_keys_side_effects
    options = {option: "random_option"}

    form_props(model: @post) do |f|
      f.text_area(:title, options)
    end

    assert_equal({option: "random_option"}, options)
  end
end
