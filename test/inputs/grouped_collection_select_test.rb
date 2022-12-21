require_relative "../test_helper"

class GroupedCollectionSelectTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  Country = Struct.new("Country", :country_id, :country_name)

  setup :setup_test_fixture

  def test_option_groups_from_collection_for_select
    @post = Post.new
    @post.country = "dk"

    form_props(model: @post) do |f|
      f.grouped_collection_select(
        :country, dummy_continents, "countries", "id", "country_id", "country_name"
      )
    end
    result = json.result!

    expected = {
      "name" => "post[country]",
      "id" => "post_country",
      "type" => "select",
      "defaultValue" => "dk",
      "options" => [
        {
          "label" => "<Africa>",
          "options" => [
            {"value" => "<sa>", "label" => "<South Africa>"},
            {"value" => "so", "label" => "Somalia"}
          ]
        }, {
          "label" => "Europe",
          "options" => [
            {"value" => "dk", "label" => "Denmark"},
            {"value" => "ie", "label" => "Ireland"}
          ]
        }
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["country"], expected)
  end

  def test_option_groups_from_collection_for_select_with_callable_group_method
    group_proc = proc { |c| c.countries }
    @post = Post.new
    @post.country = "dk"

    form_props(model: @post) do |f|
      f.grouped_collection_select(
        :country, dummy_continents, group_proc, "id", "country_id", "country_name"
      )
    end
    result = json.result!

    expected = {
      "name" => "post[country]",
      "id" => "post_country",
      "type" => "select",
      "defaultValue" => "dk",
      "options" => [
        {
          "label" => "<Africa>",
          "options" => [
            {"value" => "<sa>", "label" => "<South Africa>"},
            {"value" => "so", "label" => "Somalia"}
          ]
        }, {
          "label" => "Europe",
          "options" => [
            {"value" => "dk", "label" => "Denmark"},
            {"value" => "ie", "label" => "Ireland"}
          ]
        }
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["country"], expected)
  end

  def test_option_groups_from_collection_for_select_with_callable_group_label_method
    label_proc = proc { |c| c.id }
    @post = Post.new
    @post.country = "dk"

    form_props(model: @post) do |f|
      f.grouped_collection_select(
        :country, dummy_continents, "countries", label_proc, "country_id", "country_name"
      )
    end
    result = json.result!

    expected = {
      "name" => "post[country]",
      "id" => "post_country",
      "type" => "select",
      "defaultValue" => "dk",
      "options" => [
        {
          "label" => "<Africa>",
          "options" => [
            {"value" => "<sa>", "label" => "<South Africa>"},
            {"value" => "so", "label" => "Somalia"}
          ]
        }, {
          "label" => "Europe",
          "options" => [
            {"value" => "dk", "label" => "Denmark"},
            {"value" => "ie", "label" => "Ireland"}
          ]
        }
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["country"], expected)
  end

  private

  def dummy_continents
    [Continent.new("<Africa>", [Country.new("<sa>", "<South Africa>"), Country.new("so", "Somalia")]),
      Continent.new("Europe", [Country.new("dk", "Denmark"), Country.new("ie", "Ireland")])]
  end
end
