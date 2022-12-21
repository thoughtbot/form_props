require_relative "../test_helper"

class CollectionSelectTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_collection_select
    @post = Post.new
    @post.author_name = "Babe"

    form_props(model: @post) do |f|
      f.collection_select(:author_name, dummy_posts, "author_name", "author_name")
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[author_name]",
      "id" => "post_author_name",
      "defaultValue" => "Babe",
      "options" => [
        {"value" => "<Abe>", "label" => "<Abe>"},
        {"value" => "Babe", "label" => "Babe"},
        {"value" => "Cabe", "label" => "Cabe"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["authorName"], expected)
  end

  def test_collection_select_under_fields_for
    @post = Post.new
    @post.author_name = "Babe"

    json.output do
      fields_for :post, @post, builder: FormProps::FormBuilder do |f|
        f.collection_select(:author_name, dummy_posts, :author_name, :author_name)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[author_name]",
      "id" => "post_author_name",
      "defaultValue" => "Babe",
      "options" => [
        {"value" => "<Abe>", "label" => "<Abe>"},
        {"value" => "Babe", "label" => "Babe"},
        {"value" => "Cabe", "label" => "Cabe"}
      ]
    }

    assert_equal(JSON.parse(result)["output"]["authorName"], expected)
  end

  def test_collection_select_under_fields_for_with_index
    @post = Post.new
    @post.author_name = "Babe"

    json.output do
      fields_for :post, @post, index: 815, builder: FormProps::FormBuilder do |f|
        f.collection_select(:author_name, dummy_posts, :author_name, :author_name)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[815][author_name]",
      "id" => "post_815_author_name",
      "defaultValue" => "Babe",
      "options" => [
        {"value" => "<Abe>", "label" => "<Abe>"},
        {"value" => "Babe", "label" => "Babe"},
        {"value" => "Cabe", "label" => "Cabe"}
      ]
    }

    assert_equal(JSON.parse(result)["output"]["authorName"], expected)
  end

  def test_collection_select_under_fields_for_with_auto_index
    @post = Post.new
    @post.author_name = "Babe"
    @post.instance_eval do
      def to_param
        815
      end
    end

    json.output do
      fields_for "post[]", @post, builder: FormProps::FormBuilder do |f|
        f.collection_select(:author_name, dummy_posts, :author_name, :author_name)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[815][author_name]",
      "id" => "post_815_author_name",
      "defaultValue" => "Babe",
      "options" => [
        {"value" => "<Abe>", "label" => "<Abe>"},
        {"value" => "Babe", "label" => "Babe"},
        {"value" => "Cabe", "label" => "Cabe"}
      ]
    }

    assert_equal(JSON.parse(result)["output"]["authorName"], expected)
  end

  def test_collection_select_with_blank_and_style
    @post = Post.new
    @post.author_name = "Babe"

    form_props(model: @post) do |f|
      f.collection_select(:author_name, dummy_posts, "author_name", "author_name", {include_blank: true}, {"style" => "width: 200px"})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "style" => "width: 200px",
      "name" => "post[author_name]",
      "id" => "post_author_name",
      "defaultValue" => "Babe",
      "options" => [
        {"value" => "", "label" => " "},
        {"value" => "<Abe>", "label" => "<Abe>"},
        {"value" => "Babe", "label" => "Babe"},
        {"value" => "Cabe", "label" => "Cabe"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["authorName"], expected)
  end

  def test_collection_select_with_blank_as_string_and_style
    @post = Post.new
    @post.author_name = "Babe"

    form_props(model: @post) do |f|
      f.collection_select(:author_name, dummy_posts, "author_name", "author_name", {include_blank: "No Selection"}, {"style" => "width: 200px"})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "style" => "width: 200px",
      "name" => "post[author_name]",
      "id" => "post_author_name",
      "defaultValue" => "Babe",
      "options" => [
        {"value" => "", "label" => "No Selection"},
        {"value" => "<Abe>", "label" => "<Abe>"},
        {"value" => "Babe", "label" => "Babe"},
        {"value" => "Cabe", "label" => "Cabe"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["authorName"], expected)
  end

  def test_collection_select_with_multiple_option_appends_array_brackets_and_hidden_input
    @post = Post.new
    @post.author_name = "Babe"

    # Should suffix default name with [].
    form_props(model: @post) do |f|
      f.collection_select(:author_name, dummy_posts, "author_name", "author_name", {include_blank: true}, {multiple: true})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "multiple" => true,
      "name" => "post[author_name][]",
      "id" => "post_author_name",
      "defaultValue" => ["Babe"],
      "options" => [
        {"value" => "", "label" => " "},
        {"value" => "<Abe>", "label" => "<Abe>"},
        {"value" => "Babe", "label" => "Babe"},
        {"value" => "Cabe", "label" => "Cabe"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["authorName"], expected)

    # Shouldn't suffix custom name with [].
    form_props(model: @post) do |f|
      f.collection_select(:author_name, dummy_posts, "author_name", "author_name", {include_blank: true, name: "post[author_name][]"}, {multiple: true})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "multiple" => true,
      "name" => "post[author_name][]",
      "id" => "post_author_name",
      "defaultValue" => ["Babe"],
      "options" => [
        {"value" => "", "label" => " "},
        {"value" => "<Abe>", "label" => "<Abe>"},
        {"value" => "Babe", "label" => "Babe"},
        {"value" => "Cabe", "label" => "Cabe"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["authorName"], expected)
  end

  def test_collection_select_with_blank_and_selected
    @post = Post.new
    @post.author_name = "Babe"

    form_props(model: @post) do |f|
      f.collection_select(:author_name, dummy_posts, "author_name", "author_name", include_blank: true, selected: "<Abe>")
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[author_name]",
      "id" => "post_author_name",
      "defaultValue" => "<Abe>",
      "options" => [
        {"value" => "", "label" => " "},
        {"value" => "<Abe>", "label" => "<Abe>"},
        {"value" => "Babe", "label" => "Babe"},
        {"value" => "Cabe", "label" => "Cabe"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["authorName"], expected)
  end

  def test_collection_select_with_disabled
    @post = Post.new
    @post.author_name = "Babe"

    form_props(model: @post) do |f|
      f.collection_select(:author_name, dummy_posts, "author_name", "author_name", disabled: "Cabe")
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[author_name]",
      "id" => "post_author_name",
      "defaultValue" => "Babe",
      "options" => [
        {"value" => "<Abe>", "label" => "<Abe>"},
        {"value" => "Babe", "label" => "Babe"},
        {"value" => "Cabe", "label" => "Cabe", "disabled" => true}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["authorName"], expected)
  end

  def test_collection_select_with_proc_for_value_method
    @post = Post.new

    form_props(model: @post) do |f|
      f.collection_select(:author_name, dummy_posts, lambda { |p| p.author_name }, "title")
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[author_name]",
      "id" => "post_author_name",
      "options" => [
        {"value" => "<Abe>", "label" => "<Abe> went home"},
        {"value" => "Babe", "label" => "Babe went home"},
        {"value" => "Cabe", "label" => "Cabe went home"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["authorName"], expected)
  end

  def test_collection_select_with_proc_for_text_method
    @post = Post.new

    form_props(model: @post) do |f|
      f.collection_select(:author_name, dummy_posts, "author_name", lambda { |p| p.title })
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[author_name]",
      "id" => "post_author_name",
      "options" => [
        {"value" => "<Abe>", "label" => "<Abe> went home"},
        {"value" => "Babe", "label" => "Babe went home"},
        {"value" => "Cabe", "label" => "Cabe went home"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["authorName"], expected)
  end

  private

  def dummy_posts
    [Post.new(1, "<Abe> went home", "<Abe>", "To a little house", "shh!"),
      Post.new(2, "Babe went home", "Babe", "To a little house", "shh!"),
      Post.new(3, "Cabe went home", "Cabe", "To a little house", "shh!")]
  end
end
