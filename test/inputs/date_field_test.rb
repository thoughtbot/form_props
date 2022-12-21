require_relative "../test_helper"

class DateFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_date_field
    @post.written_on = nil

    form_props(model: @post) do |f|
      f.date_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "date",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_date_field_with_datetime_value
    @post.written_on = DateTime.new(2004, 6, 15, 1, 2, 3)

    form_props(model: @post) do |f|
      f.date_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "date",
      "defaultValue" => "2004-06-15",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_date_field_with_extra_attrs
    @post.written_on = DateTime.new(2004, 6, 15)
    min_value = DateTime.new(2000, 6, 15)
    max_value = DateTime.new(2010, 8, 15)
    step = 60

    form_props(model: @post) do |f|
      f.date_field(:written_on, min: min_value, max: max_value, step: step)
    end

    result = json.result!.strip
    expected = {
      "type" => "date",
      "defaultValue" => "2004-06-15",
      "step" => 60,
      "max" => "2010-08-15",
      "min" => "2000-06-15",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_date_field_with_value_attr
    @post.written_on = DateTime.new(2004, 6, 15)

    form_props(model: @post) do |f|
      f.date_field(:written_on, value: Date.new(2013, 6, 29))
    end

    result = json.result!.strip
    expected = {
      "type" => "date",
      "defaultValue" => "2013-06-29",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_date_field_with_timewithzone_value
    previous_time_zone, Time.zone = Time.zone, "UTC"
    @post.written_on = Time.zone.parse("2004-06-15 15:30:45")

    form_props(model: @post) do |f|
      f.date_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "date",
      "defaultValue" => "2004-06-15",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  ensure
    Time.zone = previous_time_zone
  end

  def test_date_field_with_nil_value
    @post.written_on = nil

    form_props(model: @post) do |f|
      f.date_field(:written_on)
    end

    result = json.result!.strip
    expected = {
      "type" => "date",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_date_field_with_string_values_for_min_and_max
    @post.written_on = DateTime.new(2004, 6, 15)
    min_value = "2000-06-15"
    max_value = "2010-08-15"

    form_props(model: @post) do |f|
      f.date_field(:written_on, min: min_value, max: max_value)
    end

    result = json.result!.strip
    expected = {
      "type" => "date",
      "defaultValue" => "2004-06-15",
      "max" => "2010-08-15",
      "min" => "2000-06-15",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end

  def test_date_field_with_invalid_string_values_for_min_and_max
    @post.written_on = DateTime.new(2004, 6, 15, 1, 2, 3)
    min_value = "foo"
    max_value = "bar"

    form_props(model: @post) do |f|
      f.date_field(:written_on, min: min_value, max: max_value)
    end

    result = json.result!.strip
    expected = {
      "type" => "date",
      "defaultValue" => "2004-06-15",
      "name" => "post[written_on]",
      "id" => "post_written_on"
    }

    assert_equal(JSON.parse(result)["inputs"]["writtenOn"], expected)
  end
end
