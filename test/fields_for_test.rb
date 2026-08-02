require_relative "./test_helper"

class FieldsForTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture


  def test_fields_for_with_symbol_and_object
    json.output do
      fields_for :post, @post, builder: FormProps::FormBuilder do |f|
        f.text_field(:title)
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[title]", result["output"]["title"]["name"]
    assert_equal "post_title", result["output"]["title"]["id"]
    assert_equal "Hello World", result["output"]["title"]["defaultValue"]
  end

  def test_fields_for_with_non_nested_association_and_without_object
    form_props(model: @post) do |f|
      f.fields_for(:category) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    field = result["inputs"]["name"]
    assert_equal "post[category][name]", field["name"]
    assert_equal "post_category_name", field["id"]
  end

  def test_fields_for_with_object_only
    form_props(model: @post) do |f|
      f.fields_for(@comment) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    field = result["inputs"]["name"]
    assert_equal "post[comment][name]", field["name"]
    assert_equal "post_comment_name", field["id"]
  end


  def test_fields_for_with_index
    json.output do
      fields_for :post, @post, index: 108, builder: FormProps::FormBuilder do |f|
        f.text_field(:title)
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[108][title]", result["output"]["title"]["name"]
    assert_equal "post_108_title", result["output"]["title"]["id"]
  end

  def test_fields_for_with_nil_index_override
    json.output do
      fields_for "post[]", @post, index: nil, builder: FormProps::FormBuilder do |f|
        f.text_field(:title)
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[][title]", result["output"]["title"]["name"]
    assert_equal "post__title", result["output"]["title"]["id"]
  end

  def test_fields_for_with_string_index_override
    json.output do
      fields_for "post[]", @post, index: "abc", builder: FormProps::FormBuilder do |f|
        f.text_field(:title)
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[abc][title]", result["output"]["title"]["name"]
    assert_equal "post_abc_title", result["output"]["title"]["id"]
  end


  def test_fields_for_with_auto_index
    json.output do
      fields_for "post[]", @post, builder: FormProps::FormBuilder do |f|
        f.text_field(:title)
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[123][title]", result["output"]["title"]["name"]
    assert_equal "post_123_title", result["output"]["title"]["id"]
  end


  def test_fields_for_with_index_on_parent
    json.output do
      fields_for :post, @post, index: 1, builder: FormProps::FormBuilder do |f|
        f.text_field(:title)
        f.fields_for(:category) do |cf|
          cf.text_field(:name)
        end
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[1][title]", result["output"]["title"]["name"]
    assert_equal "post[1][category][name]", result["output"]["name"]["name"]
    assert_equal "post_1_category_name", result["output"]["name"]["id"]
  end

  def test_fields_for_with_index_on_parent_and_child
    json.output do
      fields_for :post, @post, index: 1, builder: FormProps::FormBuilder do |f|
        f.fields_for(:category, @comment, index: 5) do |cf|
          cf.text_field(:name)
        end
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[1][category][5][name]", result["output"]["name"]["name"]
    assert_equal "post_1_category_5_name", result["output"]["name"]["id"]
  end

  def test_fields_for_with_index_on_child_only
    form_props(model: @post) do |f|
      f.fields_for(:category, @comment, index: 5) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    field = result["inputs"]["name"]
    assert_equal "post[category][5][name]", field["name"]
    assert_equal "post_category_5_name", field["id"]
  end


  def test_fields_for_with_auto_index_on_parent
    json.output do
      fields_for "post[]", @post, builder: FormProps::FormBuilder do |f|
        f.fields_for(:category, @comment) do |cf|
          cf.text_field(:name)
        end
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[123][category][name]", result["output"]["name"]["name"]
    assert_equal "post_123_category_name", result["output"]["name"]["id"]
  end

  def test_fields_for_with_auto_index_on_both
    json.output do
      fields_for "post[]", @post, builder: FormProps::FormBuilder do |f|
        f.fields_for("category[]", @post) do |cf|
          cf.text_field(:title)
        end
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[123][category][123][title]", result["output"]["title"]["name"]
    assert_equal "post_123_category_123_title", result["output"]["title"]["id"]
  end

  def test_fields_for_with_auto_index_on_parent_and_explicit_index_on_child
    json.output do
      fields_for "post[]", @post, builder: FormProps::FormBuilder do |f|
        f.fields_for(:category, @post, index: 5) do |cf|
          cf.text_field(:title)
        end
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[123][category][5][title]", result["output"]["title"]["name"]
    assert_equal "post_123_category_5_title", result["output"]["title"]["id"]
  end

  def test_fields_for_with_explicit_index_on_parent_and_auto_index_on_child
    json.output do
      fields_for :post, @post, index: 1, builder: FormProps::FormBuilder do |f|
        f.fields_for("category[]", @post) do |cf|
          cf.text_field(:title)
        end
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "post[1][category][123][title]", result["output"]["title"]["name"]
    assert_equal "post_1_category_123_title", result["output"]["title"]["id"]
  end


  def test_fields_for_child_with_bracket_syntax
    @comment.save
    form_props(model: @post) do |f|
      f.fields_for("comment[]", @comment) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    field = result["inputs"]["name"]
    assert_equal "post[comment][1][name]", field["name"]
    assert_equal "post_comment_1_name", field["id"]
  end


  def test_deep_nested_fields_for
    @comment.save
    form_props(scope: :posts) do |f|
      f.fields_for("post[]", @post) do |f2|
        f2.text_field(:id)
        f2.fields_for("comment[]", @comment) do |cf|
          cf.text_field(:name)
        end
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "posts[post][0][comment][1][name]", result["inputs"]["name"]["name"]
    assert_equal "posts_post_0_comment_1_name", result["inputs"]["name"]["id"]
  end


  def test_fields_for_with_bracketed_name
    json.output do
      fields_for "author[post]", @post, builder: FormProps::FormBuilder do |f|
        f.text_field(:title)
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "author[post][title]", result["output"]["title"]["name"]
    assert_equal "author_post_title", result["output"]["title"]["id"]
  end

  def test_fields_for_with_bracketed_name_and_index
    json.output do
      fields_for "author[post]", @post, index: 1, builder: FormProps::FormBuilder do |f|
        f.text_field(:title)
      end
    end
    result = JSON.parse(json.result!.strip)

    assert_equal "author[post][1][title]", result["output"]["title"]["name"]
    assert_equal "author_post_1_title", result["output"]["title"]["id"]
  end


  def test_fields_for_with_radio_button_and_index
    form_props(model: @post) do |f|
      f.fields_for(:category, @post, index: 5) do |cf|
        cf.radio_button(:title, "hello")
      end
    end
    result = JSON.parse(json.result!.strip)

    field = result["inputs"]["titleHello"]
    assert_equal "radio", field["type"]
    assert_equal "post[category][5][title]", field["name"]
    assert_equal "post_category_5_title_hello", field["id"]
    assert_equal "hello", field["value"]
  end
end
