require_relative "../test_helper"

class InputOptionsTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_tag_builder_with_conditional_hash_classes
    form_props(model: @post) do |f|
      f.text_field(:body, class: [{song: true}, {play: false}])
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["body"]["className"], "song")

    form_props(model: @post) do |f|
      f.text_field(:body, class: {song: true, play: false})
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["body"]["className"], "song")

    form_props(model: @post) do |f|
      f.text_field(:body, class: [{song: true}, nil, false])
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["body"]["className"], "song")

    form_props(model: @post) do |f|
      f.text_field(:body, class: ["song", {foo: false}])
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["body"]["className"], "song")

    form_props(model: @post) do |f|
      f.text_field(:body, class: {song: true, play: true})
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["body"]["className"], "song play")

    form_props(model: @post) do |f|
      f.text_field(:body, class: {song: false, play: false})
    end
    result = json.result!.strip

    assert_equal(JSON.parse(result)["inputs"]["body"]["className"], "")
  end

  def test_tag_builder_with_empty_array_class
    @post = Post.new
    @post.body = "test"
    form_props(model: @post) do |f|
      f.text_field(:body, class: [])
    end

    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[body]",
      "id" => "post_body",
      "defaultValue" => "test",
      "className" => ""
    }

    assert_equal(JSON.parse(result)["inputs"]["body"], expected)
  end

  def test_data_attributes
    @post = Post.new
    @post.body = "test"
    form_props(model: @post) do |f|
      f.text_field(:body, data: {a_float: 3.14, a_big_decimal: BigDecimal("-123.456"), a_number: 1, string: "hello", symbol: :foo, array: [1, 2, 3], hash: {key: "value"}, string_with_quotes: 'double"quote"party"'})
    end

    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[body]",
      "id" => "post_body",
      "defaultValue" => "test",
      "data-a-float" => "3.14",
      "data-a-big-decimal" => "-123.456",
      "data-a-number" => "1",
      "data-array" => "[1,2,3]",
      "data-hash" => "{\"key\":\"value\"}",
      "data-string-with-quotes" => "double\"quote\"party\"",
      "data-string" => "hello",
      "data-symbol" => "foo"
    }

    assert_equal(JSON.parse(result)["inputs"]["body"], expected)
  end

  def test_aria_attributes
    @post = Post.new
    @post.body = "test"

    form_props(model: @post) do |f|
      f.text_field(:body, aria: {nil: nil, a_float: 3.14, a_big_decimal: BigDecimal("-123.456"), a_number: 1, truthy: true, falsey: false, string: "hello", symbol: :foo, array: [1, 2, 3], empty_array: [], hash: {a: true, b: "truthy", falsey: false, nil: nil}, empty_hash: {}, tokens: ["a", {b: true, c: false}], empty_tokens: [{a: false}], string_with_quotes: 'double"quote"party"'})
    end

    result = json.result!.strip

    expected = {
      "type" => "text",
      "name" => "post[body]",
      "id" => "post_body",
      "defaultValue" => "test",
      "aria-a-float" => "3.14",
      "aria-a-big-decimal" => "-123.456",
      "aria-a-number" => "1",
      "aria-truthy" => "true",
      "aria-falsey" => "false",
      "aria-array" => "1 2 3",
      "aria-hash" => "a b",
      "aria-tokens" => "a b",
      "aria-string-with-quotes" => "double\"quote\"party\"",
      "aria-string" => "hello",
      "aria-symbol" => "foo"
    }

    assert_equal(JSON.parse(result)["inputs"]["body"], expected)
  end
end
