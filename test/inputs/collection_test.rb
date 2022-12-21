require_relative "../test_helper"

Category = Struct.new(:id, :name)

class CollectionTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def assert_no_select(selector, value = nil)
    assert_select(selector, text: value, count: 0)
  end

  def with_collection_radio_buttons(object_name, method_name, collection, value, label, options = {}, html_options = {}, &block)
    fields_for_options = {builder: FormProps::FormBuilder}
    if options[:index]
      fields_for_options[:index] = options[:index]
    end

    json.output do
      fields_for object_name, nil, fields_for_options do |f|
        f.collection_radio_buttons(method_name, collection, value, label, options, html_options)
      end
    end
    result = json.result!.strip

    key_name = method_name.to_s.camelize(:lower)
    output = render_js(<<-JS)
      let formProps = #{result}
      return (
        <CollectionRadioButtons {...formProps["output"]["#{key_name}"]} />
      )
    JS

    @output_buffer = ActiveSupport::SafeBuffer.new(output)
  end

  def with_collection_check_boxes(object_name, method_name, collection, value, label, options = {}, html_options = {}, &block)
    fields_for_options = {builder: FormProps::FormBuilder}
    if options[:index]
      fields_for_options[:index] = options[:index]
    end

    json.output do
      fields_for object_name, nil, fields_for_options do |f|
        f.collection_check_boxes(method_name, collection, value, label, options, html_options)
      end
    end
    result = json.result!.strip

    key_name = method_name.to_s.camelize(:lower)
    output = render_js(<<-JS)
      let formProps = #{result}
      return (
        <CollectionCheckBoxes {...formProps["output"]["#{key_name}"]} />
      )
    JS

    @output_buffer = ActiveSupport::SafeBuffer.new(output)
  end

  # COLLECTION RADIO BUTTONS
  test "collection radio accepts a collection and generates inputs from value method" do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s

    assert_select "input[type=radio][value=true]#user_active_true"
    assert_select "input[type=radio][value=false]#user_active_false"
  end

  test "collection radio accepts a collection and generates inputs from label method" do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s

    assert_select "label[for=user_active_true]", "true"
    assert_select "label[for=user_active_false]", "false"
  end

  test "collection radio handles camelized collection values for labels correctly" do
    with_collection_radio_buttons :user, :active, ["Yes", "No"], :to_s, :to_s

    assert_select "label[for=user_active_yes]", "Yes"
    assert_select "label[for=user_active_no]", "No"
  end

  test "collection radio generates labels for non-English values correctly" do
    with_collection_radio_buttons :user, :title, ["Господин", "Госпожа"], :to_s, :to_s

    assert_select "input[type=radio]#user_title_господин"
    assert_select "label[for=user_title_господин]", "Господин"
  end

  test "collection radio should sanitize collection values for labels correctly" do
    with_collection_radio_buttons :user, :name, ["$0.99", "$1.99"], :to_s, :to_s
    assert_select "label[for=user_name_0_99]", "$0.99"
    assert_select "label[for=user_name_1_99]", "$1.99"
  end

  test "collection radio correctly builds unique DOM IDs for float values" do
    with_collection_radio_buttons :user, :name, [1.0, 10], :to_s, :to_s
    assert_select "label[for=user_name_1_0]", "1.0"
    assert_select "label[for=user_name_10]", "10"
    assert_select 'input#user_name_1_0[type=radio][value="1.0"]'
    assert_select 'input#user_name_10[type=radio][value="10"]'
  end

  test "collection radio accepts checked item" do
    with_collection_radio_buttons :user, :active, [[1, true], [0, false]], :last, :first, checked: true

    assert_select "input[type=radio][value=true][checked=\"\"]"
    assert_no_select "input[type=radio][value=false][checked=\"\"]"
  end

  test "collection radio accepts multiple disabled items" do
    collection = [[1, true], [0, false], [2, "other"]]
    with_collection_radio_buttons :user, :active, collection, :last, :first, disabled: [true, false]

    assert_select "input[type=radio][value=true][disabled=\"\"]"
    assert_select "input[type=radio][value=false][disabled=\"\"]"
    assert_no_select "input[type=radio][value=other][disabled=\"\"]"
  end

  test "collection radio accepts single disabled item" do
    collection = [[1, true], [0, false]]
    with_collection_radio_buttons :user, :active, collection, :last, :first, disabled: true

    assert_select "input[type=radio][value=true][disabled=\"\"]"
    assert_no_select "input[type=radio][value=false][disabled=\"\"]"
  end

  test "collection radio accepts multiple readonly items" do
    collection = [[1, true], [0, false], [2, "other"]]
    with_collection_radio_buttons :user, :active, collection, :last, :first, read_only: [true, false]

    assert_select "input[type=radio][value=true][readonly='']"
    assert_select "input[type=radio][value=false][readonly='']"
    assert_no_select "input[type=radio][value=other][readonly='']"
  end

  test "collection radio accepts single readonly item" do
    collection = [[1, true], [0, false]]
    with_collection_radio_buttons :user, :active, collection, :last, :first, read_only: true

    assert_select "input[type=radio][value=true][readonly='']"
    assert_no_select "input[type=radio][value=false][readonly='']"
  end

  test "collection radio accepts html options as input" do
    collection = [[1, true], [0, false]]
    with_collection_radio_buttons :user, :active, collection, :last, :first, {}, {class: "special-radio"}

    assert_select "input[type=radio][value=true].special-radio#user_active_true"
    assert_select "input[type=radio][value=false].special-radio#user_active_false"
  end

  test "collection radio accepts html options as the last element of array" do
    collection = [[1, true, {class: "foo"}], [0, false, {class: "bar"}]]
    with_collection_radio_buttons :user, :active, collection, :second, :first

    assert_select "input[type=radio][value=true].foo#user_active_true"
    assert_select "input[type=radio][value=false].bar#user_active_false"
  end

  test "collection radio does not include the input class in the respective label" do
    collection = [[1, true, {class: "foo"}], [0, false, {class: "bar"}]]
    with_collection_radio_buttons :user, :active, collection, :second, :first

    assert_no_select "label.foo[for=user_active_true]"
    assert_no_select "label.bar[for=user_active_false]"
  end

  test "collection radio does not wrap input inside the label" do
    with_collection_radio_buttons :user, :active, [true, false], :to_s, :to_s

    assert_select "input[type=radio] + label"
    assert_no_select "label input"
  end
  test "collection radio accepts checked item which has a value of false" do
    with_collection_radio_buttons :user, :active, [[1, true], [0, false]], :last, :first, checked: false
    assert_no_select "input[type=radio][value=true][checked=\"\"]"
    assert_select "input[type=radio][value=false][checked=\"\"]"
  end

  test "collection radio buttons generates only one hidden field for the entire collection, to ensure something will be sent back to the server when posting an empty collection" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_radio_buttons :user, :category_ids, collection, :id, :name

    assert_select "input[type=hidden][name='user[category_ids]'][value=''][autocomplete='off']", count: 1
  end

  test "collection radio buttons generates a hidden field using the given :name in :html_options" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_radio_buttons :user, :category_ids, collection, :id, :name, {}, {name: "user[other_category_ids]"}

    assert_select "input[type=hidden][name='user[other_category_ids]'][value=''][autocomplete='off']", count: 1
  end

  test "collection radio buttons generates a hidden field with index if it was provided" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_radio_buttons :user, :category_ids, collection, :id, :name, index: 322

    assert_select "input[type=hidden][name='user[322][category_ids]'][value=''][autocomplete='off']", count: 1
  end

  test "collection radio buttons does not generate a hidden field if include_hidden option is false" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_radio_buttons :user, :category_ids, collection, :id, :name, include_hidden: false

    assert_select "input[type=hidden][name='user[category_ids]'][value='']", count: 0
  end

  test "collection radio buttons does not generate a hidden field if include_hidden option is false with key as string" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_radio_buttons :user, :category_ids, collection, :id, :name, "include_hidden" => false

    assert_select "input[type=hidden][name='user[category_ids]'][value='']", count: 0
  end

  # COLLECTION CHECK BOXES
  test "collection check boxes accepts a collection and generate a series of checkboxes for value method" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_check_boxes :user, :category_ids, collection, :id, :name

    assert_select 'input#user_category_ids_1[type=checkbox][value="1"]'
    assert_select 'input#user_category_ids_2[type=checkbox][value="2"]'
  end

  test "collection check boxes generates only one hidden field for the entire collection, to ensure something will be sent back to the server when posting an empty collection" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_check_boxes :user, :category_ids, collection, :id, :name

    assert_select "input[type=hidden][name='user[category_ids][]'][value=''][autocomplete='off']", count: 1
  end

  test "collection check boxes generates a hidden field using the given :name in :html_options" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_check_boxes :user, :category_ids, collection, :id, :name, {}, {name: "user[other_category_ids][]"}

    assert_select "input[type=hidden][name='user[other_category_ids][]'][value=''][autocomplete='off']", count: 1
  end

  test "collection check boxes generates a hidden field with index if it was provided" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_check_boxes :user, :category_ids, collection, :id, :name, index: 322

    assert_select "input[type=hidden][name='user[322][category_ids][]'][value=''][autocomplete='off']", count: 1
  end

  test "collection check boxes does not generate a hidden field if include_hidden option is false" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_check_boxes :user, :category_ids, collection, :id, :name, include_hidden: false

    assert_select "input[type=hidden][name='user[category_ids][]'][value='']", count: 0
  end

  test "collection check boxes does not generate a hidden field if include_hidden option is false with key as string" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_check_boxes :user, :category_ids, collection, :id, :name, "include_hidden" => false

    assert_select "input[type=hidden][name='user[category_ids][]'][value='']", count: 0
  end

  test "collection check boxes accepts a collection and generate a series of checkboxes with labels for label method" do
    collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
    with_collection_check_boxes :user, :category_ids, collection, :id, :name

    assert_select "label[for=user_category_ids_1]", "Category 1"
    assert_select "label[for=user_category_ids_2]", "Category 2"
  end

  test "collection check boxes handles camelized collection values for labels correctly" do
    with_collection_check_boxes :user, :active, ["Yes", "No"], :to_s, :to_s

    assert_select "label[for=user_active_yes]", "Yes"
    assert_select "label[for=user_active_no]", "No"
  end

  test "collection check box should sanitize collection values for labels correctly" do
    with_collection_check_boxes :user, :name, ["$0.99", "$1.99"], :to_s, :to_s
    assert_select "label[for=user_name_0_99]", "$0.99"
    assert_select "label[for=user_name_1_99]", "$1.99"
  end

  test "collection check boxes correctly builds unique DOM IDs for float values" do
    with_collection_check_boxes :user, :name, [1.0, 10], :to_s, :to_s
    assert_select "label[for=user_name_1_0]", "1.0"
    assert_select "label[for=user_name_10]", "10"
    assert_select 'input#user_name_1_0[type=checkbox][value="1.0"]'
    assert_select 'input#user_name_10[type=checkbox][value="10"]'
  end

  test "collection check boxes generates labels for non-English values correctly" do
    with_collection_check_boxes :user, :title, ["Господин", "Госпожа"], :to_s, :to_s

    assert_select "input[type=checkbox]#user_title_господин"
    assert_select "label[for=user_title_господин]", "Господин"
  end

  test "collection check boxes accepts html options as the last element of array" do
    collection = [[1, "Category 1", {class: "foo"}], [2, "Category 2", {class: "bar"}]]
    with_collection_check_boxes :user, :active, collection, :first, :second

    assert_select 'input[type=checkbox][value="1"].foo'
    assert_select 'input[type=checkbox][value="2"].bar'
  end

  test "collection check boxes propagates input id to the label for attribute" do
    collection = [[1, "Category 1", {id: "foo"}], [2, "Category 2", {id: "bar"}]]
    with_collection_check_boxes :user, :active, collection, :first, :second

    assert_select 'input[type=checkbox][value="1"]#foo'
    assert_select 'input[type=checkbox][value="2"]#bar'

    assert_select "label[for=foo]"
    assert_select "label[for=bar]"
  end

  test "collection check boxes does not include the input class in the respective label" do
    collection = [[1, "Category 1", {class: "foo"}], [2, "Category 2", {class: "bar"}]]
    with_collection_check_boxes :user, :active, collection, :second, :first

    assert_no_select "label.foo[for=user_active_category_1]"
    assert_no_select "label.bar[for=user_active_category_2]"
  end

  test "collection check boxes accepts selected values as :checked option" do
    collection = (1..3).map { |i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, checked: [1, 3]

    assert_select 'input[type=checkbox][value="1"][checked=""]'
    assert_select 'input[type=checkbox][value="3"][checked=""]'
    assert_no_select 'input[type=checkbox][value="2"][checked=""]'
  end

  test "collection check boxes accepts selected string values as :checked option" do
    collection = (1..3).map { |i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, checked: ["1", "3"]

    assert_select 'input[type=checkbox][value="1"][checked=""]'
    assert_select 'input[type=checkbox][value="3"][checked=""]'
    assert_no_select 'input[type=checkbox][value="2"][checked=""]'
  end

  test "collection check boxes accepts a single checked value" do
    collection = (1..3).map { |i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, checked: 3

    assert_select 'input[type=checkbox][value="3"][checked=""]'
    assert_no_select 'input[type=checkbox][value="1"][checked=""]'
    assert_no_select 'input[type=checkbox][value="2"][checked=""]'
  end

  # test "collection check boxes accepts selected values as :checked option and override the model values" do
  #   user = Struct.new(:category_ids).new(2)
  #   collection = (1..3).map { |i| [i, "Category #{i}"] }
  #
  #   @output_buffer = fields_for(:user, user) do |p|
  #     p.collection_check_boxes :category_ids, collection, :first, :last, checked: [1, 3]
  #   end
  #
  #   assert_select 'input[type=checkbox][value="1"][checked=""]'
  #   assert_select 'input[type=checkbox][value="3"][checked=""]'
  #   assert_no_select 'input[type=checkbox][value="2"][checked=""]'
  # end
  #
  test "collection check boxes accepts multiple disabled items" do
    collection = (1..3).map { |i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, disabled: [1, 3]

    assert_select 'input[type=checkbox][value="1"][disabled=""]'
    assert_select 'input[type=checkbox][value="3"][disabled=""]'
    assert_no_select 'input[type=checkbox][value="2"][disabled=""]'
  end

  test "collection check boxes accepts single disabled item" do
    collection = (1..3).map { |i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, disabled: 1

    assert_select 'input[type=checkbox][value="1"][disabled=""]'
    assert_no_select 'input[type=checkbox][value="3"][disabled=""]'
    assert_no_select 'input[type=checkbox][value="2"][disabled=""]'
  end

  test "collection check boxes accepts a proc to disabled items" do
    collection = (1..3).map { |i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, disabled: proc { |i| i.first == 1 }

    assert_select 'input[type=checkbox][value="1"][disabled=""]'
    assert_no_select 'input[type=checkbox][value="3"][disabled=""]'
    assert_no_select 'input[type=checkbox][value="2"][disabled=""]'
  end

  test "collection check boxes accepts multiple readonly items" do
    collection = (1..3).map { |i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, read_only: [1, 3]

    assert_select 'input[type=checkbox][value="1"][readonly=""]'
    assert_select 'input[type=checkbox][value="3"][readonly=""]'
    assert_no_select 'input[type=checkbox][value="2"][readonly=""]'
  end

  test "collection check boxes accepts single readonly item" do
    collection = (1..3).map { |i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, read_only: 1

    assert_select 'input[type=checkbox][value="1"][readonly=""]'
    assert_no_select 'input[type=checkbox][value="3"][readonly=""]'
    assert_no_select 'input[type=checkbox][value="2"][readonly=""]'
  end

  test "collection check boxes accepts a proc to readonly items" do
    collection = (1..3).map { |i| [i, "Category #{i}"] }
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, read_only: proc { |i| i.first == 1 }

    assert_select 'input[type=checkbox][value="1"][readonly=""]'
    assert_no_select 'input[type=checkbox][value="3"][readonly=""]'
    assert_no_select 'input[type=checkbox][value="2"][readonly=""]'
  end

  test "collection check boxes accepts html options" do
    collection = [[1, "Category 1"], [2, "Category 2"]]
    with_collection_check_boxes :user, :category_ids, collection, :first, :last, {}, {class: "check"}

    assert_select 'input.check[type=checkbox][value="1"]'
    assert_select 'input.check[type=checkbox][value="2"]'
  end
  #
  # test "collection check boxes with fields for" do
  #   collection = [Category.new(1, "Category 1"), Category.new(2, "Category 2")]
  #   @output_buffer = fields_for(:post) do |p|
  #     p.collection_check_boxes :category_ids, collection, :id, :name
  #   end
  #
  #   assert_select 'input#post_category_ids_1[type=checkbox][value="1"]'
  #   assert_select 'input#post_category_ids_2[type=checkbox][value="2"]'
  #
  #   assert_select "label[for=post_category_ids_1]", "Category 1"
  #   assert_select "label[for=post_category_ids_2]", "Category 2"
  # end
  #
  test "collection check boxes does not wrap input inside the label" do
    with_collection_check_boxes :user, :active, [true, false], :to_s, :to_s

    assert_select "input[type=checkbox] + label"
    assert_no_select "label input"
  end
end
