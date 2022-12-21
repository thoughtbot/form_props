require_relative "../test_helper"

class WeekdaySelectTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_weekday_select
    @post = Post.new
    @post.weekday = nil

    form_props(model: @post) do |f|
      f.weekday_select(:weekday)
    end
    result = json.result!

    expected = {
      "name" => "post[weekday]",
      "id" => "post_weekday",
      "type" => "select",
      "options" => [
        {"value" => "Monday", "label" => "Monday"},
        {"value" => "Tuesday", "label" => "Tuesday"},
        {"value" => "Wednesday", "label" => "Wednesday"},
        {"value" => "Thursday", "label" => "Thursday"},
        {"value" => "Friday", "label" => "Friday"},
        {"value" => "Saturday", "label" => "Saturday"},
        {"value" => "Sunday", "label" => "Sunday"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["weekday"], expected)
  end

  def test_weekday_select_with_selected_value
    @post = Post.new
    @post.weekday = "Monday"

    form_props(model: @post) do |f|
      f.weekday_select(:weekday)
    end
    result = json.result!

    expected = {
      "name" => "post[weekday]",
      "id" => "post_weekday",
      "type" => "select",
      "defaultValue" => "Monday",
      "options" => [
        {"value" => "Monday", "label" => "Monday"},
        {"value" => "Tuesday", "label" => "Tuesday"},
        {"value" => "Wednesday", "label" => "Wednesday"},
        {"value" => "Thursday", "label" => "Thursday"},
        {"value" => "Friday", "label" => "Friday"},
        {"value" => "Saturday", "label" => "Saturday"},
        {"value" => "Sunday", "label" => "Sunday"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["weekday"], expected)
  end

  def test_weekday_select_under_fields_for
    @post = Post.new

    json.output do
      fields_for :post, @post, builder: FormProps::FormBuilder do |f|
        f.weekday_select(:weekday)
      end
    end
    result = json.result!.strip

    expected = {
      "name" => "post[weekday]",
      "id" => "post_weekday",
      "type" => "select",
      "options" => [
        {"value" => "Monday", "label" => "Monday"},
        {"value" => "Tuesday", "label" => "Tuesday"},
        {"value" => "Wednesday", "label" => "Wednesday"},
        {"value" => "Thursday", "label" => "Thursday"},
        {"value" => "Friday", "label" => "Friday"},
        {"value" => "Saturday", "label" => "Saturday"},
        {"value" => "Sunday", "label" => "Sunday"}
      ]
    }

    assert_equal(JSON.parse(result)["output"]["weekday"], expected)
  end

  def test_weekday_select_under_fields_for_with_value
    @post = Post.new
    @post.weekday = "Monday"

    json.output do
      fields_for :post, @post, builder: FormProps::FormBuilder do |f|
        f.weekday_select(:weekday)
      end
    end
    result = json.result!.strip

    expected = {
      "name" => "post[weekday]",
      "id" => "post_weekday",
      "type" => "select",
      "defaultValue" => "Monday",
      "options" => [
        {"value" => "Monday", "label" => "Monday"},
        {"value" => "Tuesday", "label" => "Tuesday"},
        {"value" => "Wednesday", "label" => "Wednesday"},
        {"value" => "Thursday", "label" => "Thursday"},
        {"value" => "Friday", "label" => "Friday"},
        {"value" => "Saturday", "label" => "Saturday"},
        {"value" => "Sunday", "label" => "Sunday"}
      ]
    }

    assert_equal(JSON.parse(result)["output"]["weekday"], expected)
  end
end
