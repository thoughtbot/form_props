require_relative "../test_helper"

class CustomEnumerable
  include Enumerable

  def each
    yield "one"
    yield "two"
  end
end

class SelectTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  class Map < Hash
    def category
      "<mus>"
    end

    def nested_under_indifferent_access
      self
    end
  end

  def test_select
    @post = Post.new
    @post.category = "<mus>"

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest])
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "<mus>",
      "options" => [
        {"value" => "abe", "label" => "abe"},
        {"value" => "<mus>", "label" => "<mus>"},
        {"value" => "hest", "label" => "hest"}
      ]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)
  end

  def test_select_without_multiple
    @post = Post.new
    @post.category = "<mus>"

    form_props(model: @post) do |f|
      f.select(:category, [])
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      # "defaultValue" => "<mus>",
      "id" => "post_category",
      "options" => []
    }
    assert_equal(JSON.parse(result)["inputs"]["category"], expected)
  end

  def test_required_select_with_default_and_selected_placeholder
    form_props(model: @post) do |f|
      f.select(:category, ["lifestyle", "programming", "spiritual"], {selected: "", disabled: "", prompt: "Choose one"}, {required: true})
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "required" => true,
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "",
      "options" => [
        {"disabled" => true, "value" => "", "label" => "Choose one"},
        {"value" => "lifestyle", "label" => "lifestyle"},
        {"value" => "programming", "label" => "programming"},
        {"value" => "spiritual", "label" => "spiritual"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["category"], expected)
  end

  def test_select_with_grouped_collection_as_nested_array
    @post = Post.new
    countries_by_continent = [
      ["<Africa>", [["<South Africa>", "<sa>"], ["Somalia", "so"]]],
      ["Europe", [["Denmark", "dk"], ["Ireland", "ie"]]]
    ]
    form_props(model: @post) do |f|
      f.select(:category, countries_by_continent)
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [
        {
          "label" => "<Africa>", "options" => [
            {"value" => "<sa>", "label" => "<South Africa>"},
            {"value" => "so", "label" => "Somalia"}
          ]
        },
        {
          "label" => "Europe", "options" => [
            {"value" => "dk", "label" => "Denmark"},
            {"value" => "ie", "label" => "Ireland"}
          ]
        }
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["category"], expected)
  end

  def test_select_with_boolean_method
    @post = Post.new
    @post.allow_comments = false
    form_props(model: @post) do |f|
      f.select(:allow_comments, %w[true false])
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[allow_comments]",
      "id" => "post_allow_comments",
      "defaultValue" => "false",
      "options" => [
        {"value" => "true", "label" => "true"},
        {"value" => "false", "label" => "false"}
      ]
    }
    assert_equal(JSON.parse(result)["inputs"]["allowComments"], expected)
  end

  def test_select_under_fields_for
    @post = Post.new
    @post.category = "<mus>"

    json.output do
      fields_for :post, @post, builder: FormProps::FormBuilder do |f|
        f.select(:category, %w[abe <mus> hest])
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "<mus>",
      "options" => [
        {"value" => "abe", "label" => "abe"},
        {"value" => "<mus>", "label" => "<mus>"},
        {"value" => "hest", "label" => "hest"}
      ]
    }
    assert_equal(JSON.parse(result)["output"]["category"], expected)
  end

  def test_fields_for_with_record_inherited_from_hash
    map = Map.new
    json.output do
      fields_for :map, map, builder: FormProps::FormBuilder do |f|
        f.select(:category, %w[abe <mus> hest])
      end
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "map[category]",
      "id" => "map_category",
      "defaultValue" => "<mus>",
      "options" => [
        {"value" => "abe", "label" => "abe"},
        {"value" => "<mus>", "label" => "<mus>"},
        {"value" => "hest", "label" => "hest"}
      ]
    }
    assert_equal(JSON.parse(result)["output"]["category"], expected)
  end

  def test_select_under_fields_for_with_index
    @post = Post.new
    @post.category = "<mus>"

    json.output do
      fields_for :post, @post, index: 108, builder: FormProps::FormBuilder do |f|
        f.select(:category, %w[abe <mus> hest])
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[108][category]",
      "id" => "post_108_category",
      "defaultValue" => "<mus>",
      "options" => [
        {"value" => "abe", "label" => "abe"},
        {"value" => "<mus>", "label" => "<mus>"},
        {"value" => "hest", "label" => "hest"}
      ]
    }
    assert_equal(JSON.parse(result)["output"]["category"], expected)
  end

  def test_select_under_fields_for_with_auto_index
    @post = Post.new
    @post.category = "<mus>"
    @post.instance_eval do
      def to_param
        108
      end
    end

    json.output do
      fields_for "post[]", @post, builder: FormProps::FormBuilder do |f|
        f.select(:category, %w[abe <mus> hest])
      end
    end
    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[108][category]",
      "id" => "post_108_category",
      "defaultValue" => "<mus>",
      "options" => [
        {"value" => "abe", "label" => "abe"},
        {"value" => "<mus>", "label" => "<mus>"},
        {"value" => "hest", "label" => "hest"}
      ]
    }
    assert_equal(JSON.parse(result)["output"]["category"], expected)
  end

  def test_select_under_fields_for_with_block
    @post = Post.new

    json.out do
      fields_for :post, @post, builder: FormProps::FormBuilder do |f|
        f.select(:category, [])
      end
    end

    result = json.result!.strip

    output = render_js(<<-JS)
      let formProps = #{result}
      return (
        <Select {...formProps["out"]["category"]}>
          <option>hello world</option>
        </Select>
      )
    JS

    assert_dom_equal(
      "<select id=\"post_category\" name=\"post[category]\"><option>hello world</option></select>",
      output
    )
  end

  def test_select_with_multiple_to_add_hidden_input
    @post = Post.new
    @post.category = "<mus>"

    form_props(model: @post) do |f|
      f.select(:category, [], {}, multiple: true)
    end
    result = json.result!.strip

    expected = {
      "multiple" => true,
      "type" => "select",
      "name" => "post[category][]",
      "id" => "post_category",
      "options" => []
    }
    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<input type=\"hidden\" name=\"post[category][]\" autocomplete=\"off\" value=\"\"/><select multiple=\"\" id=\"post_category\" name=\"post[category][]\"></select>",
      output
    )
  end

  def test_select_with_multiple_and_without_hidden_input
    form_props(model: @post) do |f|
      f.select(:category, [], {include_hidden: false}, multiple: true)
    end
    result = json.result!.strip

    expected = {
      "multiple" => true,
      "type" => "select",
      "includeHidden" => false,
      "name" => "post[category][]",
      "id" => "post_category",
      "options" => []
    }
    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select multiple=\"\" id=\"post_category\" name=\"post[category][]\"></select>",
      output
    )
  end

  def test_select_with_multiple_and_with_explicit_name_ending_with_brackets
    @post = Post.new

    form_props(model: @post) do |f|
      f.select(:category, [], {include_hidden: false}, multiple: true, name: "post[category][]")
    end
    result = json.result!.strip

    expected = {
      "multiple" => true,
      "type" => "select",
      "includeHidden" => false,
      "name" => "post[category][]",
      "id" => "post_category",
      "options" => []
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select multiple=\"\" id=\"post_category\" name=\"post[category][]\"></select>",
      output
    )
  end

  def test_select_with_multiple_and_disabled_to_add_disabled_hidden_input
    @post = Post.new

    form_props(model: @post) do |f|
      f.select(:category, [], {}, multiple: true, disabled: true)
    end

    result = json.result!.strip

    expected = {
      "multiple" => true,
      "disabled" => true,
      "type" => "select",
      "name" => "post[category][]",
      "id" => "post_category",
      "options" => []
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<input disabled=\"\"type=\"hidden\" name=\"post[category][]\" value=\"\" autocomplete=\"off\"/><select multiple=\"\" disabled=\"\" id=\"post_category\" name=\"post[category][]\"></select>",
      output
    )
  end

  def test_select_with_blank
    @post = Post.new
    @post.category = "<mus>"

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], {include_blank: true})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "<mus>",
      "options" => [{"label" => " ", "value" => ""}, {"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\" \"></option><option value=\"abe\" label=\"abe\"></option><option value=\"&lt;mus&gt;\" selected=\"\" label=\"&lt;mus&gt;\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_with_include_blank_false_and_required
    @post = Post.new
    @post.category = "<mus>"
    e = assert_raises(ArgumentError) {
      form_props(model: @post) do |f|
        f.select(:category, %w[abe <mus> hest], {include_blank: false}, {required: "required"})
      end
    }
    assert_match(/include_blank cannot be false for a required field./, e.message)
  end

  def test_select_with_blank_as_string
    @post = Post.new
    @post.category = "<mus>"

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], {include_blank: "None"})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "<mus>",
      "options" => [{"label" => "None", "value" => ""}, {"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"None\"></option><option value=\"abe\" label=\"abe\"></option><option value=\"&lt;mus&gt;\" selected=\"\" label=\"&lt;mus&gt;\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_with_blank_as_string_escaped
    @post = Post.new
    @post.category = "<mus>"

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], {include_blank: "<None>"})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "<mus>",
      "options" => [{"label" => "<None>", "value" => ""}, {"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"&lt;None&gt;\"></option><option value=\"abe\" label=\"abe\"></option><option value=\"&lt;mus&gt;\" selected=\"\" label=\"&lt;mus&gt;\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_with_default_prompt
    @post = Post.new
    @post.category = ""

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], prompt: true)
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"label" => "Please select", "value" => ""}, {"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"Please select\"></option><option value=\"abe\" label=\"abe\"></option><option value=\"&lt;mus&gt;\" label=\"&lt;mus&gt;\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_no_prompt_when_select_has_value
    @post = Post.new
    @post.category = "<mus>"

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], prompt: true)
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "<mus>",
      "options" => [{"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"abe\" label=\"abe\"></option><option selected=\"\" value=\"&lt;mus&gt;\" label=\"&lt;mus&gt;\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_with_given_prompt
    @post = Post.new
    @post.category = ""

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], prompt: "The prompt")
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"label" => "The prompt", "value" => ""}, {"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"The prompt\"></option><option value=\"abe\" label=\"abe\"></option><option value=\"&lt;mus&gt;\" label=\"&lt;mus&gt;\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_with_given_prompt_escaped
    @post = Post.new
    @post.category = ""

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], prompt: "<The prompt>")
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"label" => "<The prompt>", "value" => ""}, {"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"&lt;The prompt&gt;\"></option><option value=\"abe\" label=\"abe\"></option><option value=\"&lt;mus&gt;\" label=\"&lt;mus&gt;\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_with_prompt_and_blank
    @post = Post.new
    @post.category = ""

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], prompt: true, include_blank: true)
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"label" => "Please select", "value" => ""}, {"label" => " ", "value" => ""}, {"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"Please select\"><option value=\"\" label=\" \"></option></option><option value=\"abe\" label=\"abe\"></option><option value=\"&lt;mus&gt;\" label=\"&lt;mus&gt;\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_with_empty
    @post = Post.new
    @post.category = ""

    form_props(model: @post) do |f|
      f.select(:category, [], prompt: true, include_blank: true)
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"label" => "Please select", "value" => ""}, {"label" => " ", "value" => ""}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"Please select\"><option value=\"\" label=\" \"></option></option></option></select>",
      output
    )
  end

  def test_select_with_html_options
    @post = Post.new
    @post.category = ""

    form_props(model: @post) do |f|
      f.select(:category, [], {prompt: true, include_blank: true}, {className: "disabled", disabled: true})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "className" => "disabled",
      "disabled" => true,
      "id" => "post_category",
      "options" => [{"label" => "Please select", "value" => ""}, {"label" => " ", "value" => ""}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select class=\"disabled\" disabled=\"\" name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"Please select\"></option><option value=\"\" label=\" \"></option></select>",
      output
    )
  end

  def test_select_with_nil
    @post = Post.new
    @post.category = "othervalue"

    form_props(model: @post) do |f|
      f.select(:category, [nil, "othervalue"])
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "othervalue",
      "options" => [{"label" => "", "value" => ""}, {"label" => "othervalue", "value" => "othervalue"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"\"></option><option value=\"othervalue\" label=\"othervalue\" selected=\"\"></option></select>",
      output
    )
  end

  def test_select_with_nil_as_selected_value
    @post = Post.new
    @post.category = nil

    form_props(model: @post) do |f|
      f.select(:category, none: nil, programming: 1, economics: 2)
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "",
      "options" => [{"value" => "", "label" => "none"}, {"value" => "1", "label" => "programming"}, {"value" => "2", "label" => "economics"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option selected=\"\" value=\"\" label=\"none\"></option><option value=\"1\" label=\"programming\"></option><option value=\"2\" label=\"economics\"></option></select>",
      output
    )
  end

  def test_select_with_nil_and_selected_option_as_nil
    @post = Post.new
    @post.category = nil

    form_props(model: @post) do |f|
      f.select(:category, {none: nil, programming: 1, economics: 2}, {selected: nil})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"value" => "", "label" => "none"}, {"value" => "1", "label" => "programming"}, {"value" => "2", "label" => "economics"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"none\"></option><option value=\"1\" label=\"programming\"></option><option value=\"2\" label=\"economics\"></option></select>",
      output
    )
  end

  def test_select_with_array
    @continent = Continent.new
    @continent.countries = ["Africa", "Europe"]

    assert_dom_equal(
      %(<select name="continent[countries]" id="continent_countries"><option selected="selected" value="Africa">Africa</option>\n<option selected="selected" value="Europe">Europe</option>\n<option value="America">America</option></select>),
      select("continent", "countries", %W[Africa Europe America], {multiple: true})
    )

    form_props(model: @continent) do |f|
      f.select(:countries, %W[Africa Europe America], {multiple: true})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "continent[countries]",
      "id" => "continent_countries",
      # "multiple" => "multiple", # this will change in new versions
      "multiple" => true, # temp fix!
      "defaultValue" => ["Africa", "Europe"],
      "options" => [
        {"value" => "Africa", "label" => "Africa"},
        {"value" => "Europe", "label" => "Europe"},
        {"value" => "America", "label" => "America"}
      ]
    }

    assert_equal(JSON.parse(result)["inputs"]["countries"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["countries"]}/>
    JS

    assert_dom_equal(
      '<input type="hidden" name="continent[countries]" autocomplete="off" value=""/><select name="continent[countries]" id="continent_countries" multiple=""><option value="Africa" label="Africa" selected=""></option><option value="Europe" label="Europe" selected=""></option><option value="America" label="America"></option></select>',
      output
    )
  end

  def test_required_select
    @post = Post.new
    @post.category = nil

    form_props(model: @post) do |f|
      f.select(:category, %w[abe mus hest], {}, {required: true})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "required" => true,
      "id" => "post_category",
      "options" => [{"value" => "", "label" => " "}, {"value" => "abe", "label" => "abe"}, {"value" => "mus", "label" => "mus"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\" required=\"\"><option value=\"\" label=\" \"></option><option value=\"abe\" label=\"abe\"></option><option value=\"mus\" label=\"mus\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_required_select_with_include_blank_prompt
    @post = Post.new
    @post.category = nil

    form_props(model: @post) do |f|
      f.select(:category, %w[abe mus hest], {include_blank: "Select one"}, {required: true})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "required" => true,
      "id" => "post_category",
      "options" => [{"value" => "", "label" => "Select one"}, {"value" => "abe", "label" => "abe"}, {"value" => "mus", "label" => "mus"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\" required=\"\"><option value=\"\" label=\"Select one\"></option><option value=\"abe\" label=\"abe\"></option><option value=\"mus\" label=\"mus\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_required_select_with_prompt
    assert_dom_equal(
      %(<select id="post_category" name="post[category]" required="required"><option value="">Select one</option>\n<option value="abe">abe</option>\n<option value="mus">mus</option>\n<option value="hest">hest</option></select>),
      select("post", "category", %w[abe mus hest], {prompt: "Select one"}, {required: true})
    )

    @post = Post.new
    @post.category = nil

    form_props(model: @post) do |f|
      f.select(:category, %w[abe mus hest], {prompt: "Select one"}, {required: true})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "required" => true,
      "id" => "post_category",
      "options" => [{"value" => "", "label" => "Select one"}, {"value" => "abe", "label" => "abe"}, {"value" => "mus", "label" => "mus"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\" required=\"\"><option value=\"\" label=\"Select one\"></option><option value=\"abe\" label=\"abe\"></option><option value=\"mus\" label=\"mus\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_required_select_display_size_equals_to_one
    @post = Post.new
    @post.category = nil

    form_props(model: @post) do |f|
      f.select(:category, %w[abe mus hest], {}, {required: true, size: 1})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "size" => 1,
      "name" => "post[category]",
      "required" => true,
      "id" => "post_category",
      "options" => [{"value" => "", "label" => " "}, {"value" => "abe", "label" => "abe"}, {"value" => "mus", "label" => "mus"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\" required=\"\" size=\"1\"><option value=\"\" label=\" \"></option><option value=\"abe\" label=\"abe\"></option><option value=\"mus\" label=\"mus\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_required_select_with_display_size_bigger_than_one
    @post = Post.new
    @post.category = nil

    form_props(model: @post) do |f|
      f.select(:category, %w[abe mus hest], {}, {required: true, size: 2})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "size" => 2,
      "name" => "post[category]",
      "required" => true,
      "id" => "post_category",
      "options" => [{"value" => "abe", "label" => "abe"}, {"value" => "mus", "label" => "mus"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\" required=\"\" size=\"2\"><option value=\"abe\" label=\"abe\"></option><option value=\"mus\" label=\"mus\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_required_select_with_multiple_option
    @post = Post.new
    @post.category = nil

    form_props(model: @post) do |f|
      f.select(:category, %w[abe mus hest], {}, {required: true, multiple: true})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category][]",
      "required" => true,
      "multiple" => true,
      "id" => "post_category",
      "options" => [{"value" => "abe", "label" => "abe"}, {"value" => "mus", "label" => "mus"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<input name=\"post[category][]\" type=\"hidden\" value=\"\" autocomplete=\"off\"/><select name=\"post[category][]\" id=\"post_category\" multiple=\"\" required=\"\"><option value=\"abe\" label=\"abe\"></option><option value=\"mus\" label=\"mus\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_with_integer
    @post = Post.new
    @post.category = nil

    form_props(model: @post) do |f|
      f.select(:category, [1], {prompt: true, include_blank: true})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"value" => "", "label" => "Please select"}, {"value" => "", "label" => " "}, {"value" => "1", "label" => "1"}]
    }
    assert_equal(JSON.parse(result)["inputs"]["category"], expected)
    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"\" label=\"Please select\"></option><option label=\" \" value=\"\"></option><option value=\"1\" label=\"1\"></option></select>",
      output
    )
  end

  def test_list_of_lists
    @post = Post.new
    @post.category = nil

    form_props(model: @post) do |f|
      f.select(:category, [["Number", "number"], ["Text", "text"], ["Yes/No", "boolean"]], {prompt: true, include_blank: true})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"value" => "", "label" => "Please select"}, {"value" => "", "label" => " "}, {"value" => "number", "label" => "Number"}, {"value" => "text", "label" => "Text"}, {"value" => "boolean", "label" => "Yes/No"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)
  end

  def test_select_with_selected_value
    @post = Post.new
    @post.category = "<mus>"

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], selected: "abe")
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "abe",
      "options" => [{"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"abe\" label=\"abe\" selected=\"\"></option><option value=\"&lt;mus&gt;\" label=\"&lt;mus&gt;\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_with_index_option
    @post = Post.new

    form_props(model: @post) do |f|
      f.select("category", %w[rap rock country], {}, {index: nil})
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[][category]",
      "id" => "post__category",
      "options" => [{"value" => "rap", "label" => "rap"}, {"value" => "rock", "label" => "rock"}, {"value" => "country", "label" => "country"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[][category]\" id=\"post__category\"><option value=\"rap\" label=\"rap\"></option><option value=\"rock\" label=\"rock\"></option><option value=\"country\" label=\"country\"></option></select>",
      output
    )
  end

  def test_select_with_selected_nil
    @post = Post.new

    @post.category = "<mus>"

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], selected: nil)
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select id=\"post_category\" name=\"post[category]\"><option value=\"abe\" label=\"abe\"></option><option value=\"&lt;mus&gt;\" label=\"&lt;mus&gt;\"></option><option value=\"hest\" label=\"hest\"></option></select>",
      output
    )
  end

  def test_select_with_disabled_value
    @post = Post.new
    @post.category = "<mus>"

    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], disabled: "hest")
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "<mus>",
      "options" => [{"value" => "abe", "label" => "abe"}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest", "disabled" => true}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select id=\"post_category\" name=\"post[category]\"><option value=\"abe\" label=\"abe\"></option><option value=\"&lt;mus&gt;\" label=\"&lt;mus&gt;\" selected=\"\"></option><option value=\"hest\" label=\"hest\" disabled=\"\"></option></select>",
      output
    )
  end

  def test_select_not_existing_method_with_selected_value
    @post = Post.new

    form_props(model: @post) do |f|
      f.select(:locale, %w[en ru], disabled: "ru")
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[locale]",
      "id" => "post_locale",
      "options" => [{"value" => "en", "label" => "en"}, {"value" => "ru", "label" => "ru", "disabled" => true}]
    }

    assert_equal(JSON.parse(result)["inputs"]["locale"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["locale"]}/>
    JS

    assert_dom_equal(
      "<select id=\"post_locale\" name=\"post[locale]\"><option value=\"en\" label=\"en\"></option><option value=\"ru\" label=\"ru\" disabled=\"\"></option></select>",
      output
    )
  end

  def test_select_with_prompt_and_selected_value
    @post = Post.new

    form_props(model: @post) do |f|
      f.select(:category, %w[one two], selected: "two", prompt: true)
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "two",
      "options" => [{"value" => "one", "label" => "one"}, {"value" => "two", "label" => "two"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select id=\"post_category\" name=\"post[category]\"><option value=\"one\" label=\"one\"></option><option selected=\"\" value=\"two\" label=\"two\"></option></select>",
      output
    )
  end

  def test_select_with_disabled_array
    @post = Post.new
    @post.category = "<mus>"
    form_props(model: @post) do |f|
      f.select(:category, %w[abe <mus> hest], disabled: ["hest", "abe"])
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "defaultValue" => "<mus>",
      "options" => [{"value" => "abe", "label" => "abe", "disabled" => true}, {"value" => "<mus>", "label" => "<mus>"}, {"value" => "hest", "label" => "hest", "disabled" => true}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select id=\"post_category\" name=\"post[category]\"><option value=\"abe\" label=\"abe\" disabled=\"\"></option><option value=\"&lt;mus&gt;\" label=\"&lt;mus&gt;\" selected=\"\"></option><option value=\"hest\" label=\"hest\" disabled=\"\"></option></select>",
      output
    )
  end

  def test_select_with_range
    @post = Post.new
    @post.category = 0
    assert_dom_equal(
      "<select id=\"post_category\" name=\"post[category]\"><option value=\"1\">1</option>\n<option value=\"2\">2</option>\n<option value=\"3\">3</option></select>",
      select("post", "category", 1..3)
    )
    form_props(model: @post) do |f|
      f.select(:category, 1..3)
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"value" => "1", "label" => "1"}, {"value" => "2", "label" => "2"}, {"value" => "3", "label" => "3"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"1\" label=\"1\"></option><option value=\"2\" label=\"2\"></option><option value=\"3\"label=\"3\"></option></select>",
      output
    )
  end

  def test_select_with_enumerable
    @post = Post.new
    form_props(model: @post) do |f|
      f.select(:category, CustomEnumerable.new)
    end

    result = json.result!.strip

    expected = {
      "type" => "select",
      "name" => "post[category]",
      "id" => "post_category",
      "options" => [{"value" => "one", "label" => "one"}, {"value" => "two", "label" => "two"}]
    }

    assert_equal(JSON.parse(result)["inputs"]["category"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["category"]}/>
    JS

    assert_dom_equal(
      "<select name=\"post[category]\" id=\"post_category\"><option value=\"one\" label=\"one\"></option><option value=\"two\" label=\"two\"></option></select>",
      output
    )
  end

  def test_select_with_grouped_collection_as_hash
    @post = Post.new

    countries_by_continent = {
      "<Africa>" => [["<South Africa>", "<sa>"], ["Somalia", "so"]],
      "Europe" => [["Denmark", "dk"], ["Ireland", "ie"]]
    }

    form_props(model: @post) do |f|
      f.select(:origin, countries_by_continent)
    end

    result = json.result!.strip

    expected = {
      "name" => "post[origin]",
      "id" => "post_origin",
      "type" => "select",
      "options" => [
        {"label" => "<Africa>", "options" => [
          {"value" => "<sa>", "label" => "<South Africa>"},
          {"value" => "so", "label" => "Somalia"}
        ]},
        {"label" => "Europe", "options" => [
          {"value" => "dk", "label" => "Denmark"},
          {"value" => "ie", "label" => "Ireland"}
        ]}
      ]
    }

    assert_equal(JSON.parse(result)["inputs"]["origin"], expected)

    output = render_js(<<-JS)
      let formProps = #{result}
      return <Select {...formProps["inputs"]["origin"]}/>
    JS

    assert_dom_equal(
      [
        '<select id="post_origin" name="post[origin]"><optgroup label="&lt;Africa&gt;"><option value="&lt;sa&gt;" label="&lt;South Africa&gt;"></option>',
        '<option value="so" label="Somalia"></option></optgroup><optgroup label="Europe"><option value="dk" label="Denmark"></option>',
        '<option value="ie" label="Ireland"></option></optgroup></select>'
      ].join,
      output
    )
  end
end
