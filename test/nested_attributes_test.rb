require_relative "./test_helper"

class NestedAttributesTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture


  def test_has_one_with_new_record
    @post.author = Comment.new

    form_props(model: @post) do |f|
      f.fields_for(:author) do |af|
        af.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    author = result["inputs"]["authorAttributes"]
    assert_kind_of Hash, author
    assert_equal "post[author_attributes][name]", author["name"]["name"]
    assert_equal "post_author_attributes_name", author["name"]["id"]
    assert_nil author["id"], "New record should not have hidden id"
  end

  def test_has_one_with_persisted_record
    @post.author = Comment.new(321)

    form_props(model: @post) do |f|
      f.fields_for(:author) do |af|
        af.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    author = result["inputs"]["authorAttributes"]
    assert_equal "post[author_attributes][name]", author["name"]["name"]
    assert_equal "post_author_attributes_name", author["name"]["id"]
    assert_equal "comment #321", author["name"]["defaultValue"]

    id_field = author["id"]
    assert_not_nil id_field, "Persisted record should have hidden id"
    assert_equal "hidden", id_field["type"]
    assert_equal "post[author_attributes][id]", id_field["name"]
    assert_equal "321", id_field["defaultValue"]
  end

  def test_has_one_with_include_id_false
    @post.author = Comment.new(321)

    form_props(model: @post) do |f|
      f.fields_for(:author, include_id: false) do |af|
        af.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    author = result["inputs"]["authorAttributes"]
    assert_equal "post[author_attributes][name]", author["name"]["name"]
    assert_nil author["id"], "include_id: false should suppress hidden id"
  end

  def test_has_one_with_include_id_false_inherited_from_parent
    @post.author = Comment.new(321)

    form_props(model: @post, include_id: false) do |f|
      f.fields_for(:author) do |af|
        af.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    author = result["inputs"]["authorAttributes"]
    assert_equal "post[author_attributes][name]", author["name"]["name"]
    assert_nil author["id"], "Inherited include_id: false should suppress hidden id"
  end

  def test_has_one_with_include_id_true_override
    @post.author = Comment.new(321)

    form_props(model: @post, include_id: false) do |f|
      f.fields_for(:author, include_id: true) do |af|
        af.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    author = result["inputs"]["authorAttributes"]
    assert_not_nil author["id"], "include_id: true should override inherited false"
    assert_equal "hidden", author["id"]["type"]
    assert_equal "post[author_attributes][id]", author["id"]["name"]
  end

  def test_has_one_with_explicit_hidden_id_placement
    @post.author = Comment.new(321)

    form_props(model: @post) do |f|
      f.fields_for(:author) do |af|
        af.hidden_field(:id)
        af.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    author = result["inputs"]["authorAttributes"]

    id_field = author["id"]
    assert_not_nil id_field
    assert_equal "hidden", id_field["type"]
    assert_equal "post[author_attributes][id]", id_field["name"]
    assert_equal "321", id_field["defaultValue"]

    assert_equal "post[author_attributes][name]", author["name"]["name"]
  end


  def test_has_many_with_persisted_records
    @post.comments = [Comment.new(1, 1, "First"), Comment.new(2, 1, "Second")]

    form_props(model: @post) do |f|
      f.fields_for(:comments) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    comments = result["inputs"]["commentsAttributes"]
    assert_equal 2, comments.length

    assert_equal "post[comments_attributes][0][name]", comments[0]["name"]["name"]
    assert_equal "post_comments_attributes_0_name", comments[0]["name"]["id"]
    assert_equal "comment #1", comments[0]["name"]["defaultValue"]
    assert_equal "hidden", comments[0]["id"]["type"]
    assert_equal "post[comments_attributes][0][id]", comments[0]["id"]["name"]
    assert_equal "1", comments[0]["id"]["defaultValue"]

    assert_equal "post[comments_attributes][1][name]", comments[1]["name"]["name"]
    assert_equal "post_comments_attributes_1_name", comments[1]["name"]["id"]
    assert_equal "comment #2", comments[1]["name"]["defaultValue"]
    assert_equal "hidden", comments[1]["id"]["type"]
    assert_equal "post[comments_attributes][1][id]", comments[1]["id"]["name"]
    assert_equal "2", comments[1]["id"]["defaultValue"]
  end

  def test_has_many_with_new_records
    @post.comments = [Comment.new, Comment.new]

    form_props(model: @post) do |f|
      f.fields_for(:comments) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    comments = result["inputs"]["commentsAttributes"]
    assert_equal 2, comments.length

    assert_equal "post[comments_attributes][0][name]", comments[0]["name"]["name"]
    assert_equal "new comment", comments[0]["name"]["defaultValue"]
    assert_nil comments[0]["id"], "New record should not have hidden id"

    assert_equal "post[comments_attributes][1][name]", comments[1]["name"]["name"]
    assert_equal "new comment", comments[1]["name"]["defaultValue"]
    assert_nil comments[1]["id"], "New record should not have hidden id"
  end

  def test_has_many_with_mixed_persisted_and_new
    @post.comments = [Comment.new(321, 1, "Persisted"), Comment.new]

    form_props(model: @post) do |f|
      f.fields_for(:comments) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    comments = result["inputs"]["commentsAttributes"]
    assert_equal 2, comments.length

    assert_equal "comment #321", comments[0]["name"]["defaultValue"]
    assert_not_nil comments[0]["id"], "Persisted record should have hidden id"
    assert_equal "hidden", comments[0]["id"]["type"]
    assert_equal "321", comments[0]["id"]["defaultValue"]

    assert_equal "new comment", comments[1]["name"]["defaultValue"]
    assert_nil comments[1]["id"], "New record should not have hidden id"
  end

  def test_has_many_with_include_id_false
    @post.comments = [Comment.new(1), Comment.new(2)]
    @post.author = Comment.new(321)

    form_props(model: @post) do |f|
      f.fields_for(:author) do |af|
        af.text_field(:name)
      end
      f.fields_for(:comments, include_id: false) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    author = result["inputs"]["authorAttributes"]
    assert_not_nil author["id"], "Author should still have hidden id"

    comments = result["inputs"]["commentsAttributes"]
    assert_nil comments[0]["id"], "include_id: false should suppress hidden id"
    assert_nil comments[1]["id"], "include_id: false should suppress hidden id"
  end

  def test_has_many_with_include_id_false_inherited
    @post.comments = [Comment.new(1), Comment.new(2)]
    @post.author = Comment.new(321)

    form_props(model: @post, include_id: false) do |f|
      f.fields_for(:author) do |af|
        af.text_field(:name)
      end
      f.fields_for(:comments) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    author = result["inputs"]["authorAttributes"]
    assert_nil author["id"], "Inherited include_id: false should suppress hidden id on author"

    comments = result["inputs"]["commentsAttributes"]
    assert_nil comments[0]["id"], "Inherited include_id: false should suppress hidden id"
    assert_nil comments[1]["id"], "Inherited include_id: false should suppress hidden id"
  end

  def test_has_many_with_include_id_true_override
    @post.comments = [Comment.new(1), Comment.new(2)]
    @post.author = Comment.new(321)

    form_props(model: @post, include_id: false) do |f|
      f.fields_for(:author, include_id: true) do |af|
        af.text_field(:name)
      end
      f.fields_for(:comments) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    author = result["inputs"]["authorAttributes"]
    assert_not_nil author["id"], "include_id: true should override inherited false"

    comments = result["inputs"]["commentsAttributes"]
    assert_nil comments[0]["id"], "Comments should still inherit include_id: false"
  end

  def test_has_many_with_explicit_hidden_id_placement
    @post.comments = [Comment.new(1), Comment.new(2)]

    form_props(model: @post) do |f|
      f.fields_for(:comments) do |cf|
        cf.hidden_field(:id)
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    comments = result["inputs"]["commentsAttributes"]
    assert_equal 2, comments.length

    comments.each_with_index do |comment, i|
      id_field = comment["id"]
      assert_not_nil id_field
      assert_equal "hidden", id_field["type"]
      assert_equal "post[comments_attributes][#{i}][id]", id_field["name"]
    end
  end

  def test_has_many_with_empty_collection
    form_props(model: @post) do |f|
      f.fields_for(:comments, []) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    comments = result["inputs"]["commentsAttributes"]
    assert_equal [], comments
  end


  def test_has_many_with_supplied_collection
    @post.comments = [Comment.new(1, 1, "First"), Comment.new(2, 1, "Second")]

    form_props(model: @post) do |f|
      f.fields_for(:comments, @post.comments) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    comments = result["inputs"]["commentsAttributes"]
    assert_equal 2, comments.length
    assert_equal "comment #1", comments[0]["name"]["defaultValue"]
    assert_equal "comment #2", comments[1]["name"]["defaultValue"]
    assert_not_nil comments[0]["id"]
    assert_not_nil comments[1]["id"]
  end

  def test_has_many_with_supplied_collection_different_from_models
    different_comments = [Comment.new(10, 1, "Different 1"), Comment.new(20, 1, "Different 2")]
    @post.comments = []

    form_props(model: @post) do |f|
      f.fields_for(:comments, different_comments) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    comments = result["inputs"]["commentsAttributes"]
    assert_equal 2, comments.length
    assert_equal "comment #10", comments[0]["name"]["defaultValue"]
    assert_equal "comment #20", comments[1]["name"]["defaultValue"]
  end

  def test_has_many_auto_iterates_yielding_each_builder
    @post.comments = [Comment.new(321, 1, "First"), Comment.new(nil, nil, "New")]
    yielded_objects = []

    form_props(model: @post) do |f|
      f.fields_for(:comments) do |cf|
        yielded_objects << cf.object
        cf.text_field(:name)
      end
    end
    json.result!

    assert_equal @post.comments, yielded_objects
  end


  def test_has_many_with_explicit_child_index
    @post.comments = []

    form_props(model: @post) do |f|
      f.fields_for(:comments, Comment.new(321), child_index: "abc") do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    comments = result["inputs"]["commentsAttributes"]
    assert_equal "post[comments_attributes][abc][name]", comments[0]["name"]["name"]
    assert_equal "post_comments_attributes_abc_name", comments[0]["name"]["id"]
    assert_equal "321", comments[0]["id"]["defaultValue"]
  end

  def test_has_many_with_child_index_as_lambda
    @post.comments = []

    form_props(model: @post) do |f|
      f.fields_for(:comments, Comment.new(321), child_index: -> { "abc" }) do |cf|
        cf.text_field(:name)
      end
    end
    result = JSON.parse(json.result!.strip)

    comments = result["inputs"]["commentsAttributes"]
    assert_equal "post[comments_attributes][abc][name]", comments[0]["name"]["name"]
    assert_equal "post_comments_attributes_abc_name", comments[0]["name"]["id"]
    assert_equal "321", comments[0]["id"]["defaultValue"]
  end


  def test_deep_nesting_with_unique_indices
    @post.comments = [Comment.new(1)]
    @post.comments[0].relevances = [Tag.new(100)]
    @post.tags = [Tag.new(200)]
    @post.tags[0].relevances = [Tag.new(300)]

    form_props(model: @post) do |f|
      f.fields_for(:comments) do |cf|
        cf.text_field(:name)
        cf.fields_for(:relevances) do |rf|
          rf.text_field(:value)
        end
      end
      f.fields_for(:tags) do |tf|
        tf.text_field(:value)
        tf.fields_for(:relevances) do |rf|
          rf.text_field(:value)
        end
      end
    end
    result = JSON.parse(json.result!.strip)

    # Comments level
    comments = result["inputs"]["commentsAttributes"]
    assert_equal "post[comments_attributes][0][name]", comments[0]["name"]["name"]

    # Comments -> Relevances
    relevances = comments[0]["relevancesAttributes"]
    assert_equal "post[comments_attributes][0][relevances_attributes][0][value]",
      relevances[0]["value"]["name"]
    assert_equal "post_comments_attributes_0_relevances_attributes_0_value",
      relevances[0]["value"]["id"]

    # Tags level
    tags = result["inputs"]["tagsAttributes"]
    assert_equal "post[tags_attributes][0][value]", tags[0]["value"]["name"]

    # Tags -> Relevances (index resets to 0 for this separate association)
    tag_relevances = tags[0]["relevancesAttributes"]
    assert_equal "post[tags_attributes][0][relevances_attributes][0][value]",
      tag_relevances[0]["value"]["name"]
    assert_equal "post_tags_attributes_0_relevances_attributes_0_value",
      tag_relevances[0]["value"]["id"]
  end
end
