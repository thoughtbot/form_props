# form_props

![Build Status](https://github.com/thoughtbot/form_props/actions/workflows/build.yml/badge.svg?branch=main)

form_props is a Rails form builder that outputs HTML props instead of tags. Now
you can enjoy the power and convenience of Rails helpers in React!

By separting attributes from tags, form_props can offer greater flexbility than normal
Rails form builders; allowing designers to stay longer in HTML land and more easily
customize their form structure without needing to know Rails.

## Caution

This project is in its early phases of development. Its interface, behavior,
and name are likely to change drastically before a major version release.

## Installation

Add to your `Gemfile`

```
gem "form_props"
```

and `bundle install`

## Usage
`form_props` is designed to be used in a [PropsTemplate] template (it can work with
[jbuilder](#jbuilder)). For example in your `new.json.props`:

```ruby
json.some_form do
  form_props(@post) do |f|
    f.text :title
    f.submit
  end
end
```

would output

```
{
  someForm: {
    props: {
      id: "create-post",
      action: "/posts/123",
      acceptCharset: "UTF-8",
      method: "post"
    },
    extras: {
      method: {
        name: "_method",
        type: "hidden",
        defaultValue: "patch",
        autoComplete: "off"
      },
      utf8: {
        name: "utf8",
        type: "hidden",
        defaultValue: "\u0026#x2713;",
        autoComplete: "off"
      }
      csrf: {
        name: "utf8",
        type: "authenticity_token",
        defaultValue: "SomeTOken!23$",
        autoComplete: "off"
      }
    },
    inputs: {
      title: {name: "post[title]", id: "post_title", type: "text", defaultValue: "hello"},
      submit: {type: "submit", value: "Update a Post"}
    }
  }
}
```

You can then proceed to use this output in React like so:

```js
import React from 'react'

export default ({props, inputs, extras}) => {
  <form {...props}>
    {Object.values(extras).map((hiddenProps) => (<input {...hiddenProps} key={hiddenProps.name}/>))}

    <input {...inputs.title} />
    <label for={inputs.title.id}>Your Name</label>
    <button {...inputs.submit}>{inputs.submit.text}</button>
  </form>
}
```

### Key format
By default, props_template automatically `camelize(:lower)` on all keys. All
documentation here reflects that default. You can change that [behavior](https://github.com/thoughtbot/props_template#change-key-format)
if you wish.

## Flexibility
form_props is only concerned about attributes, the designer can focus on tag
structure and stay longer in HTML land. For example, you can decide to nest an
input inside a label.

```js
<label for={inputs.name.id}>
  Your Name
  <input {...inputs.name} type="text"/>
</label>
```

or not

```js
<label for={inputs.name.id}>Your Name</label>
<input {...inputs.name} />
```

## Custom Components

With `form_props` you can combine the comprehensiveness of Rails forms with
your prefered React components:

For example:

```js
json.some_form do
  form_props(@post) do |f|
    f.time_zone_select(:time_zone)
    ...
  end
end
```

Then use it the props your own components or a external component like
`react-select`:

```js
import React from 'react'
import Select from 'react-select';

export default (({props, inputs, extras})) => {
  return (
    <form {...props}>
      <Select
        {...inputs.timeZone}
        isMulti={inputs.timeZone.multiple}
      />
    </form>
  )
}
```

## Error handling

form_props doesn't handle form errors, but you can easily add this functionality:

```ruby
json.someForm do
  form_props(@post) do |f|
    f.text_field :title
  end

  json.errors @post.errors.to_hash(true)
end
```

then merge it later

```js
<MyTextComponent {...someForm.inputs.title, error: ...someForm.errors.title}>
```

## form_props
`form_props` shares most of same arguments as [form_with]. The differences are

1. `remote` and `local` options are removed.
2. You can change the name of the value keys generated by the [form helpers](#form-helpers)
from `defaultValue` to `value`, by using `controlled: true`. For example:

```ruby
json.some_form do
  form_props(@post, controlled: true) do |f|
    f.text_field :title
  end
end
```

By default, the `controlled` option is `false`.

###

`props` Attributes that you can splat directly into your `<form>` element.


`extras` contain hidden input attributes that are created by form_props
indirectly, for example, the `csrf` token. Its best to wrap this in a custom
component that does the following. An [Extra] component is available

```js
Object.values(extras).map((hiddenProps) => (<input {...hiddenProps} type="hidden"/>))}
```


## Form Helpers

`form_props` provides its own version of the following Rails form helpers:

```
check_box                 file_field                submit
collection_check_boxes    grouped_collection_select tel_field
collection_helpers        hidden_field              text_area
collection_radio_buttons  month_field               text_field
collection_select         number_field              time_field
color_field               password_field            time_zone_select
date_field                radio_button              url_field
datetime_field            range_field               week_field
datetime_local_field      search_field              weekday_select
email_field               select
```

`form_props` is a fork of `form_with`, and the accompanying form builder
inherits from `ActionView::Helpers::FormBuilder`.

Many of the helpers accept the same arguments and you can continue to rely on
[Rails Guides for form helpers] for guidance, but as the goal of `form_props`
is to focus on attributes instead of tags there are a few general differences
across all helpers that would beneficial to know:

1. The form helper `f.label` do not exist. Helpers like the below that `yield`s
for label structure

```
f.collection_radio_buttons(:active, [true, false], :to_s, :to_s) do |b|
  b.label { b.radio_button + b.text }
end
```

no longer takes in blocks to do so.

2. `defaultValue`s are not escaped. Instead, we lean on PropsTemplate
to [escape] JSON and HTML entities.
3. `defaultValue` will not appear as a key if no `value` was set.
3. `data-disable-with` is removed on submit buttons.
4. `data-remote` is removed from form props.
5. For helpers selectively render hidden inputs, we passed the attribute to
5. `f.select` helpers does not render `selected` on `options`, instead it follows
react caveats and renders on the input's `value`. For example:

```js
{
  "type": "select",
  "name": "continent[countries]",
  "id": "continent_countries",
  "multiple": true,
  "defaultValue": ["Africa", "Europe"],
  "options": [
    {"value": "Africa", "label": "Africa"},
    {"value": "Europe", "label": "Europe"},
    {"value": "America", "label": "America", "disabled": true}
  ]
}
```

### Unsupported helpers
`form_props` does **not** support:

`label`. We encourage you to use the tag directly in combination with other
helpers. For example:

```
<label for={inputs.name.id} />
```

`rich_text_area`. We encourage you to use the `f.text_area` helper in
combination with Trix wrapped in React, or TinyMCE's react component.

`button`. We encourage you to use the tag directly.

`date_select`, `time_select`, `datetime_select`. We encourage you to use other
alternatives like `react-date-picker` in combination with other supported date
field helpers.

## Text helpers

[text_field], [email_field], [tel_field], [file_field], [url_field],
[hidden_field], and the slight variations [password_field],
[search_field], [color_field] has the same arguments as their Rails
counterpart.

When used like so

```ruby
form_props(model: @post) do |f|
  f.text_field(:title)
end
```

`inputs.title` would output

```
{
  "type": "text",
  "defaultValue": "Hello World",
  "name": "post[title]",
  "id": "post_title"
}
```

## Date helpers
[date_field], [datetime_field], [datetime_local_field], [month_field],
[week_field] has the same arguments as their Rails counterparts.

When used like so

```ruby
form_props(model: @post) do |f|
  f.datetime_field(:created_at)
end
```

`inputs.created_at` would output

```json
{
  "type": "datetime-local",
  "defaultValue": "2004-06-15T01:02:03",
  "name": "post[created_at]",
  "id": "post_created_at"
}
```

## Number helpers
[number_field], [range_field] has the same arguments as their Rails counterparts.

When used like so

```ruby
@post.favs = 2

form_props(model: @post) do |f|
  f.range_field(:favs, in: 1...10)
end
```

`inputs.favs` would output

```json
{
  "type": "range",
  "defaultValue": "2",
  "name": "post[favs]",
  "min": 1,
  "max": 9,
  "id": "post_favs"
}
```

## Checkbox helper
[check_box] has the same arguments its Rails counterpart.

The original Rails `check_box` helper renders an unchecked value in a
hidden input. While `form_props` doesn't generate the tags, the
`unchecked_value`, and `include_hidden` can be passed to a React component
to replicate that behavior. This repository has an example [CheckBox]
component used in its test that you can refer to.

When used like so:

```ruby
@post.admin = "on"

form_props(model: @post) do |f|
  f.check_box(:admin, {}, "on", "off")
end
```

`inputs.admin` would output

```json
{
  "type": "checkbox",
  "defaultValue": "on",
  "uncheckedValue": "off",
  "name": "post[admin]",
  "id": "post_admin",
  "includeHidden": true
}
```

## Radio helper
[radio_button] has the same arguments as its Rails counterpart. The radio button is unique

When used like so:

```ruby
@post.admin = false

form_props(model: @post) do |f|
  f.radio_button(:admin, true)
  f.radio_button(:admin, false)
end
```

The keys on `inputs` are a combination of the name and value. So `inputs.adminTrue`
would output:

```json
{
  "type": "radio",
  "defaultValue": "true",
  "name": "post[admin]",
  "id": "post_admin_true"
}
```

and `inputs.adminFalse` would output

```json
{
  "type": "radio",
  "defaultValue": "false",
  "name": "post[admin]",
  "id": "post_admin_false",
  "checked": true
}
```

## Select helpers
[select], [weekday_select], [time_zone_select] mostly has the same arguments
as its Rails counterpart. They key difference is that choices for select cannot be a string:

```ruby
# BAD!!!

form_props(model: @post) do |f|
  f.select(:category, "<option><option/>", multiple: false)
end

# Good

form_props(model: @post) do |f|
  f.select(:category, [], multiple: false)
end
```

When used like so

```ruby
@post.category = "lifestyle"

form_props(model: @post) do |f|
  f.select(:category, ["lifestyle", "programming", "spiritual"], {selected: "", disabled: "", prompt: "Choose one"}, {required: true})
end

```

`inputs.category` would output

```
{
  "type": "select",
  "required": true,
  "name": "post[category]",
  "id": "post_category",
  "defaultValue":"lifestyle",
  "options": [
    {"disabled": true, "value": "", "label": "Choose one"},
    {"value": "lifestyle", "label": "lifestyle"},
    {"value": "programming", "label": "programming"},
    {"value": "spiritual", "label": "spiritual"}
  ]
}
```

Of note:
1. Notice that we follow react caveats and put `selected` values on `defaultValue`. This rule
does not apply to the `disabled` attribute on option.
2. When `multiple: true`, `defaultValue` is an array of values.
3. The key, `defaultValue` is only set if the value is in options. For example:

```
form_props(model: @post) do |f|
  f.select(:category, [])
end
```

would output in `inputs.category`:

```
{
  "type": "select",
  "name": "post[category]",
  "id": "post_category",
  "options": []
}
```

As the `select` helper renders nested options and `includeHidden`, a custom
component is required to correctly render the tag structure. A reference
[Select component] implementation is availble that is used in our tests.

The `select` helper can also output a grouped collection.

```ruby
@post = Post.new
countries_by_continent = [
  ["<Africa>", [["<South Africa>", "<sa>"], ["Somalia", "so"]]],
  ["Europe", [["Denmark", "dk"], ["Ireland", "ie"]]]
]

form_props(model: @post) do |f|
  f.select(:category, countries_by_continent)
end
```

`inputs.category` would output:

```json
{
  "type": "select",
  "name": "post[category]",
  "id": "post_category",
  "options": [
    {
      "label": "<Africa>", "options": [
        {"value": "<sa>", "label": "<South Africa>"},
        {"value": "so", "label": "Somalia"}
      ]
    },
    {
      "label": "Europe", "options": [
        {"value": "dk", "label": "Denmark"},
        {"value": "ie", "label": "Ireland"}
      ]
    }
  ]
}
```


## Group collection select
[group_collection_select] has the same arguments its Rails counterpart.

Like `select`, you'll need combine this with a custom `Select` component. An
example [Select component] is available.

When used like so:

```ruby

@post = Post.new
@post.country = "dk"
label_proc = proc { |c| c.id }

continents = [
  Continent.new("<Africa>", [Country.new("<sa>", "<South Africa>"), Country.new("so", "Somalia")]),
  Continent.new("Europe", [Country.new("dk", "Denmark"), Country.new("ie", "Ireland")])
]

form_props(model: @post) do |f|
  f.grouped_collection_select(
    :country, continents, "countries", label_proc, "country_id", "country_name"
  )
end
```

`inputs.country` would output

```json
{
  "name": "post[country]",
  "id": "post_country",
  "type": "select",
  "defaultValue": "dk",
  "options": [
    {
      "label":"<Africa>",
      "options": [
        {"value": "<sa>", "label": "<South Africa>"},
        {"value": "so", "label": "Somalia"}
      ]
    }, {
      "label": "Europe",
      "options": [
        {"value": "dk", "label": "Denmark"},
        {"value":"ie", "label": "Ireland"}
      ]
    }
  ]
}
```

## Collection select
[collection_select], [collection_radio_buttons], and [collection_check_boxes]
has the same arguments its Rails counterpart, but their output differs slightly.


[collection_select] follows the same output as `f.select`. When used like so:

```
dummy_posts = [
  Post.new(1, "<Abe> went home", "<Abe>", "To a little house", "shh!"),
  Post.new(2, "Babe went home", "Babe", "To a little house", "shh!"),
  Post.new(3, "Cabe went home", "Cabe", "To a little house", "shh!")
]


form_props(model: @post) do |f|
  f.collection_select(:author_name, dummy_posts, "author_name", "author_name")
end
```

`inputs.authorName` would output:

```
{
  "type": "select",
  "name": "post[author_name]",
  "id": "post_author_name",
  "defaultValue": "Babe",
  "options": [
    {"value": "<Abe>", "label": "<Abe>"},
    {"value": "Babe", "label": "Babe"},
    {"value": "Cabe", "label": "Cabe"}
  ]
}
```

[collection_radio_buttons] and [collection_check_boxes] usage is the same with
their rails counterpart, and when used, would render:

```
{
  "collection": [
    {"name":"user[other_category_ids][]","type": "checkbox", "defaultValue": "1", "uncheckedValue":"","id":"user_category_ids_1","label": "Category 1"},
    {"name":"user[other_category_ids][]","type": "checkbox", "defaultValue": "2", "uncheckedValue":"","id":"user_category_ids_2","label": "Category 2"}
  ],
  "name": "user[other_category_ids][]",
  "includeHidden": true
}
```

Like select, you would need a custom component to render. An example
implementation for [CollectionCheckBoxes] and [CollectionRadioButtons] are
available.

## jbuilder

form_props can work with jbuilder, but needs an extra call in the beginning of
your template to `FormProps.set` to inject `json`. For example.

```ruby
FormProps.set(json, self)

json.data do
  json.hello "world"

  json.form do
    form_props(model: User.new, url: "/") do |f|
      f.text_field(:email)
      f.submit
    end
  end
end
```

[escape]: https://github.com/thoughtbot/props_template#escape-mode
[form_with]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[Extra]: ./components/Extras.js
[CollectionCheckBoxes]: ./components/CollectionCheckBoxes.js
[CollectionRadioButtons]: ./components/CollectionRadioButtons.js
[Select Component]: ./components/Select.js
[select]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormBuilder.html#method-i-select
[CheckBox]: ./components/CheckBox.js
[PropsTemplate]: https://github.com/thoughtbot/props_template
[text_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-text_field
[tel_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-tel_field
[file_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-file_field
[week_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-week_field
[url_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-url_field
[telephone_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-telephone_field
[text_area]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-text_area
[text_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-text_field
[time_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-time_field
[search_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-search_field
[radio_button]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-radio_button
[range_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-range_field
[password_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-password_field
[phone_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-phone_field
[number_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-number_field
[month_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-month_field
[hidden_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-hidden_field
[fields]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-fields
[fields_for]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for
[field_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-file_field
[form_with]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[email_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-email_field
[date_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-date_field
[datetime_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-datetime_field
[datetime_local_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-datetime_local_field
[check_box]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-check_box
[color_field]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormHelper.html#method-i-color_field
[grouped_collection_select]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-grouped_collection_select
[collection_radio_buttons]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons
[collection_select]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select
[collection_check_boxes]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes
[weekday_select]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormBuilder.html#method-i-weekday_select
[group_collection_select]: https://api.rubyonrails.org/v7.0.4.2/classes/ActionView/Helpers/FormBuilder.html#method-i-grouped_collection_select

## Special Thanks

Thanks to [bootstrap_form](https://github.com/bootstrap-ruby/bootstrap_form) documentation for inspiration.

