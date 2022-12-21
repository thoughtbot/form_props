require_relative "../test_helper"

class WeekFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_week_field
    form_props(model: @post) do |f|
      f.week_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "week",
      "name" => "post[written_on]",
      "id" => "post_written_on",
      "defaultValue" => "2004-W25"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_week_field_with_nil_value
    @post.written_on = nil

    form_props(model: @post) do |f|
      f.week_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "week",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_week_field_with_extra_attrs
    @post.written_on = DateTime.new(2004, 6, 15, 1, 2, 3)
    min_value = DateTime.new(2000, 2, 13)
    max_value = DateTime.new(2010, 12, 23)
    step = 2

    form_props(model: @post) do |f|
      f.week_field(:written_on, min: min_value, max: max_value, step: step)
    end

    result = json.result!.strip
    expected = {
      "type" => "week",
      "defaultValue" => "2004-W25",
      "step" => 2,
      "min" => "2000-W06",
      "max" => "2010-W51",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_week_field_with_timewithzone_value
    previous_week_zone, Time.zone = Time.zone, "UTC"
    @post.written_on = Time.zone.parse("2004-06-15 15:30:45")

    form_props(model: @post) do |f|
      f.week_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "week",
      "defaultValue" => "2004-W25",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  ensure
    Time.zone = previous_week_zone
  end

  def test_week_field_week_number_base
    @post.written_on = DateTime.new(2015, 1, 1, 1, 2, 3)

    form_props(model: @post) do |f|
      f.week_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "week",
      "defaultValue" => "2015-W01",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end
end
