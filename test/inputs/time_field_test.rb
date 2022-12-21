require_relative "../test_helper"

class TimeFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_time_field
    @post.written_on = nil

    form_props(model: @post) do |f|
      f.time_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "time",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_time_field_with_datetime_value
    @post.written_on = DateTime.new(2004, 6, 15, 1, 2, 3)

    form_props(model: @post) do |f|
      f.time_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "time",
      "defaultValue" => "01:02:03.000",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_time_field_with_extra_attrs
    @post.written_on = DateTime.new(2004, 6, 15, 1, 2, 3)
    min_value = DateTime.new(2000, 6, 15, 20, 45, 30)
    max_value = DateTime.new(2010, 8, 15, 10, 25, 0o0)
    step = 60

    form_props(model: @post) do |f|
      f.time_field(:written_on, min: min_value, max: max_value, step: step)
    end

    result = json.result!.strip
    expected = {
      "type" => "time",
      "defaultValue" => "01:02:03.000",
      "step" => 60,
      "max" => "10:25:00.000",
      "min" => "20:45:30.000",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_time_field_with_timewithzone_value
    previous_time_zone, Time.zone = Time.zone, "UTC"
    @post.written_on = Time.zone.parse("2004-06-15 01:02:03")

    form_props(model: @post) do |f|
      f.time_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "time",
      "defaultValue" => "01:02:03.000",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  ensure
    Time.zone = previous_time_zone
  end

  def test_time_field_with_nil_value
    @post.written_on = nil

    form_props(model: @post) do |f|
      f.time_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "time",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_time_field_with_string_values_for_min_and_max
    @post.written_on = DateTime.new(2004, 6, 15, 1, 2, 3)
    min_value = "20:45:30.000"
    max_value = "10:25:00.000"

    form_props(model: @post) do |f|
      f.time_field(:written_on, min: min_value, max: max_value)
    end

    result = json.result!.strip
    expected = {
      "type" => "time",
      "defaultValue" => "01:02:03.000",
      "max" => "10:25:00.000",
      "min" => "20:45:30.000",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_time_field_with_invalid_string_values_for_min_and_max
    @post.written_on = DateTime.new(2004, 6, 15, 1, 2, 3)
    min_value = "foo"
    max_value = "bar"

    form_props(model: @post) do |f|
      f.time_field(:written_on, min: min_value, max: max_value)
    end

    result = json.result!.strip
    expected = {
      "type" => "time",
      "defaultValue" => "01:02:03.000",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end
end
