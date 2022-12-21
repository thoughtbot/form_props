require_relative "../test_helper"

class TimeZoneSelectTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  module FakeZones
    FakeZone = Struct.new(:name) do
      def to_s
        name
      end

      def =~(_re)
      end

      def match?(_re)
      end
    end

    module ClassMethods
      def [](id)
        fake_zones ? fake_zones[id] : super
      end

      def all
        fake_zones ? fake_zones.values : super
      end

      def dummy
        :test
      end
    end

    def self.prepended(base)
      base.mattr_accessor(:fake_zones)
      class << base
        prepend ClassMethods
      end
    end
  end

  ActiveSupport::TimeZone.prepend FakeZones

  setup do
    setup_test_fixture

    ActiveSupport::TimeZone.fake_zones = %w[A B C D E].index_with do |id|
      FakeZones::FakeZone.new(id)
    end

    @fake_timezones = ActiveSupport::TimeZone.all
  end

  teardown do
    ActiveSupport::TimeZone.fake_zones = nil
  end

  def test_time_zone_select
    @post = Post.new
    @post.time_zone = "D"

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone)
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "defaultValue" => "D",
      "options" => [
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end

  def test_time_zone_select_under_fields_for
    @post = Post.new
    @post.time_zone = "D"

    json.output do
      fields_for :post, @post, builder: FormProps::FormBuilder do |f|
        f.time_zone_select(:time_zone)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "defaultValue" => "D",
      "options" => [
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["output"]["timeZone"], expected)
  end

  def test_time_zone_select_under_fields_for_with_index
    @post = Post.new
    @post.time_zone = "D"

    json.output do
      fields_for :post, @post, index: 305, builder: FormProps::FormBuilder do |f|
        f.time_zone_select(:time_zone)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[305][time_zone]",
      "id" => "post_305_time_zone",
      "defaultValue" => "D",
      "options" => [
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["output"]["timeZone"], expected)
  end

  def test_time_zone_select_under_fields_for_with_auto_index
    @post = Post.new
    @post.time_zone = "D"
    @post.instance_eval do
      def to_param
        305
      end
    end

    json.output do
      fields_for "post[]", @post, builder: FormProps::FormBuilder do |f|
        f.time_zone_select(:time_zone)
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[305][time_zone]",
      "id" => "post_305_time_zone",
      "defaultValue" => "D",
      "options" => [
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["output"]["timeZone"], expected)
  end

  def test_time_zone_select_with_blank
    @post = Post.new
    @post.time_zone = "D"

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, nil, {include_blank: true})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "defaultValue" => "D",
      "options" => [
        {"value" => "", "label" => " "},
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end

  def test_time_zone_select_with_blank_as_string
    @post = Post.new
    @post.time_zone = "D"

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, nil, {include_blank: "No Zone"})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "defaultValue" => "D",
      "options" => [
        {"value" => "", "label" => "No Zone"},
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end

  def test_time_zone_select_with_style
    @post = Post.new
    @post.time_zone = "D"

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, nil, {}, {"style" => "color: red"})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "style" => "color: red",
      "defaultValue" => "D",
      "options" => [
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end

  def test_time_zone_select_with_blank_and_style
    @post = Post.new
    @post.time_zone = "D"

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, nil, {include_blank: true}, {"style" => "color: red"})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "style" => "color: red",
      "defaultValue" => "D",
      "options" => [
        {"value" => "", "label" => " "},
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, nil, {include_blank: true}, {style: "color: red"})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "style" => "color: red",
      "defaultValue" => "D",
      "options" => [
        {"value" => "", "label" => " "},
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end

  def test_time_zone_select_with_blank_as_string_and_style
    @post = Post.new
    @post.time_zone = "D"

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, nil, {include_blank: "No Zone"}, {"style" => "color: red"})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "style" => "color: red",
      "defaultValue" => "D",
      "options" => [
        {"value" => "", "label" => "No Zone"},
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, nil, {include_blank: "No Zone"}, {style: "color: red"})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "style" => "color: red",
      "defaultValue" => "D",
      "options" => [
        {"value" => "", "label" => "No Zone"},
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end

  def test_time_zone_select_with_priority_zones
    @post = Post.new
    @post.time_zone = "D"
    zones = [ActiveSupport::TimeZone.new("A"), ActiveSupport::TimeZone.new("D")]

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, zones)
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "defaultValue" => "D",
      "options" => [
        {"value" => "A", "label" => "A"},
        {"value" => "D", "label" => "D"},
        {"label" => "-------------", "value" => "", "disabled" => true},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end

  def test_time_zone_select_with_priority_zones_as_regexp
    @post = Post.new
    @post.time_zone = "D"
    @fake_timezones.each do |tz|
      def tz.=~(re)
        %(A D).include?(name)
      end

      def tz.match?(re)
        %(A D).include?(name)
      end
    end

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, /A|D/)
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "defaultValue" => "D",
      "options" => [
        {"value" => "A", "label" => "A"},
        {"value" => "D", "label" => "D"},
        {"label" => "-------------", "value" => "", "disabled" => true},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end

  def test_time_zone_select_with_priority_zones_is_not_implemented_with_grep
    @post = Post.new
    @post.time_zone = "D"

    # `time_zone_select` can't be written with `grep` because Active Support
    # time zones don't support implicit string coercion with `to_str`.
    @fake_timezones.each do |tz|
      def tz.===(zone)
        raise StandardError
      end
    end

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, /A|D/)
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "defaultValue" => "D",
      "options" => [
        {"label" => "-------------", "value" => "", "disabled" => true},
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end

  def test_time_zone_select_with_default_time_zone_and_nil_value
    @post = Post.new
    @post.time_zone = nil

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, nil, default: "B")
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "defaultValue" => "B",
      "options" => [
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end

  def test_time_zone_select_with_default_time_zone_and_value
    @post = Post.new
    @post.time_zone = "D"

    form_props(model: @post) do |f|
      f.time_zone_select(:time_zone, nil, default: "B")
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[time_zone]",
      "id" => "post_time_zone",
      "defaultValue" => "D",
      "options" => [
        {"value" => "A", "label" => "A"},
        {"value" => "B", "label" => "B"},
        {"value" => "C", "label" => "C"},
        {"value" => "D", "label" => "D"},
        {"value" => "E", "label" => "E"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["timeZone"], expected)
  end
end
