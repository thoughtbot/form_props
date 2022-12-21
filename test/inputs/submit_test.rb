require_relative "../test_helper"

class SubmitTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_submit_with_object_as_new_record_and_locale_strings
    I18n.with_locale :submit do
      @post.persisted = false
      @post.stub(:to_key, nil) do
        form_props(model: @post) do |f|
          f.submit
        end

        result = json.result!.strip

        expected = {
          "type" => "submit",
          "defaultValue" => "Create Post",
          "name" => "commit"
        }

        assert_equal(JSON.parse(result)["inputs"]["submit"], expected)
      end
    end
  end

  def test_submit_with_object_as_existing_record_and_locale_strings
    I18n.with_locale :submit do
      form_props(model: @post, method: "patch") do |f|
        f.submit
      end

      result = json.result!.strip

      expected = {
        "type" => "submit",
        "defaultValue" => "Confirm Post changes",
        "name" => "commit"
      }

      assert_equal(JSON.parse(result)["inputs"]["submit"], expected)
      assert_equal(JSON.parse(result)["extras"]["method"]["defaultValue"], "patch")
    end
  end

  def test_submit_without_object_and_locale_strings
    I18n.with_locale :submit do
      form_props(scope: :post) do |f|
        f.submit
      end

      result = json.result!.strip

      expected = {
        "type" => "submit",
        "defaultValue" => "Save changes",
        "name" => "commit"
      }

      assert_equal(JSON.parse(result)["inputs"]["submit"], expected)
    end
  end

  def test_submit_with_object_which_is_overwritten_by_scope_option
    I18n.with_locale :submit do
      form_props(model: @post, scope: :another_post) do |f|
        f.submit
      end
      result = json.result!.strip

      expected = {
        "type" => "submit",
        "defaultValue" => "Update your Post",
        "name" => "commit"
      }

      assert_equal(JSON.parse(result)["extras"]["method"]["defaultValue"], "patch")
      assert_equal(JSON.parse(result)["inputs"]["submit"], expected)
    end
  end

  def test_submit_with_object_which_is_namespaced
    blog_post = Blog::Post.new("And his name will be forty and four.", 44)
    I18n.with_locale :submit do
      form_props(model: blog_post) do |f|
        f.submit
      end

      result = json.result!.strip

      expected = {
        "type" => "submit",
        "defaultValue" => "Update your Post",
        "name" => "commit"
      }

      assert_equal(JSON.parse(result)["extras"]["method"]["defaultValue"], "patch")
      assert_equal(JSON.parse(result)["inputs"]["submit"], expected)
    end
  end
end
