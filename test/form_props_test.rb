require_relative "./test_helper"

class FormPropsTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def url_for(options)
    if options.is_a?(Hash)
      "http://www.example.com"
    else
      super
    end
  end

  def test_form_with_multipart
    form_props(multipart: true)

    expected = {
      extras: {
        utf8: {
          name: "utf8",
          type: "hidden",
          defaultValue: "&#x2713;",
          autoComplete: "off"
        }
      },
      props: {
        encType: "multipart/form-data",
        action: "http://www.example.com",
        acceptCharset: "UTF-8",
        method: "post"
      }
    }.to_json

    result = json.result!.strip

    assert_equal(result, expected)
  end

  def test_form_with_with_method_patch
    form_props(method: :patch)

    expected = {
      extras: {
        method: {
          name: "_method",
          type: "hidden",
          defaultValue: "patch",
          autoComplete: "off"
        },
        utf8: {
          name: "utf8",
          type: "hidden",
          defaultValue: "&#x2713;",
          autoComplete: "off"
        }
      },
      props: {
        action: "http://www.example.com",
        acceptCharset: "UTF-8",
        method: "post"
      }
    }.to_json

    result = json.result!.strip

    assert_equal(result, expected)
  end

  def test_form_with_with_method_put
    form_props(method: :put)

    expected = {
      extras: {
        method: {
          name: "_method",
          type: "hidden",
          defaultValue: "put",
          autoComplete: "off"
        },
        utf8: {
          name: "utf8",
          type: "hidden",
          defaultValue: "&#x2713;",
          autoComplete: "off"
        }
      },
      props: {
        action: "http://www.example.com",
        acceptCharset: "UTF-8",
        method: "post"
      }
    }.to_json

    result = json.result!.strip

    assert_equal(result, expected)
  end

  def test_form_with_with_method_delete
    form_props(method: :delete)

    expected = {
      extras: {
        method: {
          name: "_method",
          type: "hidden",
          defaultValue: "delete",
          autoComplete: "off"
        },
        utf8: {
          name: "utf8",
          type: "hidden",
          defaultValue: "&#x2713;",
          autoComplete: "off"
        }
      },
      props: {
        action: "http://www.example.com",
        acceptCharset: "UTF-8",
        method: "post"
      }
    }.to_json

    result = json.result!.strip
    assert_equal(result, expected)
  end

  def test_form_with_false_url
    form_props(url: false)
    expected = {
      extras: {
        utf8: {
          name: "utf8",
          type: "hidden",
          defaultValue: "&#x2713;",
          autoComplete: "off"
        }
      },
      props: {
        acceptCharset: "UTF-8",
        method: "post"
      }
    }.to_json

    result = json.result!.strip
    assert_equal(result, expected)
  end

  def test_form_with_false_action
    form_props(html: {action: false})

    expected = {
      extras: {
        utf8: {
          name: "utf8",
          type: "hidden",
          defaultValue: "&#x2713;",
          autoComplete: "off"
        }
      },
      props: {
        acceptCharset: "UTF-8",
        method: "post"
      }
    }.to_json

    result = json.result!.strip
    assert_equal(result, expected)
  end

  def test_form_with_skip_enforcing_utf8_true
    form_props(skip_enforcing_utf8: true)

    expected = {
      extras: {},
      props: {
        action: "http://www.example.com",
        acceptCharset: "UTF-8",
        method: "post"
      }
    }.to_json

    result = json.result!.strip
    assert_equal(result, expected)
  end

  def test_form_with_default_enforce_utf8_false
    with_default_enforce_utf8 false do
      form_props
      expected = {
        extras: {},
        props: {
          action: "http://www.example.com",
          acceptCharset: "UTF-8",
          method: "post"
        }
      }.to_json

      result = json.result!.strip
      assert_equal(result, expected)
    end
  end

  def test_form_with_default_enforce_utf8_true
    with_default_enforce_utf8 true do
      form_props

      expected = {
        extras: {
          utf8: {
            name: "utf8",
            type: "hidden",
            defaultValue: "&#x2713;",
            autoComplete: "off"
          }
        },
        props: {
          action: "http://www.example.com",
          acceptCharset: "UTF-8",
          method: "post"
        }
      }.to_json

      result = json.result!.strip
      assert_equal(result, expected)
    end
  end

  def test_form_with
    form_props(model: @post, id: "create-post") do |f|
      f.text_field(:title)
      f.text_area(:body)
      f.check_box(:secret)
      f.select(:category, %w[animal economy sports])
    end

    result = json.result!.strip

    expected = {
      inputs: {
        title: {
          type: "text",
          defaultValue: "Hello World",
          name: "post[title]",
          id: "post_title"
        },
        body: {
          name: "post[body]",
          id: "post_body",
          type: "textarea",
          defaultValue: "Back to the hill and over it again!"
        },
        secret: {
          type: "checkbox",
          defaultValue: "1",
          defaultChecked: true,
          uncheckedValue: "0",
          includeHidden: true,
          name: "post[secret]",
          id: "post_secret"
        },
        category: {
          name: "post[category]",
          id: "post_category",
          type: "select",
          options: [
            {value: "animal", label: "animal"},
            {value: "economy", label: "economy"},
            {value: "sports", label: "sports"}
          ]
        }
      },
      extras: {
        method: {
          name: "_method",
          type: "hidden",
          defaultValue: "patch",
          autoComplete: "off"
        },
        utf8: {
          name: "utf8",
          type: "hidden",
          defaultValue: "\u0026#x2713;",
          autoComplete: "off"
        }
      },
      props: {
        id: "create-post",
        action: "/posts/123",
        acceptCharset: "UTF-8",
        method: "post"
      }
    }.to_json
    assert_equal(result, expected)
  end

  def test_form_with_using_controlled_option
    form_props(model: @post, id: "create-post", controlled: true) do |f|
      f.text_field(:title)
      f.text_area(:body)
      f.check_box(:secret)
      f.select(:category, %w[animal economy sports])
    end

    result = json.result!.strip

    expected = {
      inputs: {
        title: {
          type: "text",
          value: "Hello World",
          name: "post[title]",
          id: "post_title"
        },
        body: {
          name: "post[body]",
          id: "post_body",
          type: "textarea",
          value: "Back to the hill and over it again!"
        },
        secret: {
          type: "checkbox",
          value: "1",
          checked: true,
          uncheckedValue: "0",
          includeHidden: true,
          name: "post[secret]",
          id: "post_secret"
        },
        category: {
          name: "post[category]",
          id: "post_category",
          type: "select",
          options: [
            {value: "animal", label: "animal"},
            {value: "economy", label: "economy"},
            {value: "sports", label: "sports"}
          ]
        }
      },
      extras: {
        method: {
          name: "_method",
          type: "hidden",
          defaultValue: "patch",
          autoComplete: "off"
        },
        utf8: {
          name: "utf8",
          type: "hidden",
          defaultValue: "\u0026#x2713;",
          autoComplete: "off"
        }
      },
      props: {
        id: "create-post",
        action: "/posts/123",
        acceptCharset: "UTF-8",
        method: "post"
      }
    }.to_json
    assert_equal(result, expected)
  end

  def with_default_enforce_utf8(value)
    old_value = ActionView::Helpers::FormTagHelper.default_enforce_utf8
    ActionView::Helpers::FormTagHelper.default_enforce_utf8 = value

    yield
  ensure
    ActionView::Helpers::FormTagHelper.default_enforce_utf8 = old_value
  end
end
