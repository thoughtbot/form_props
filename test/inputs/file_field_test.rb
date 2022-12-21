require_relative "../test_helper"

module ActionController
  class Base
    def self.test_routes(&block)
      routes = ActionDispatch::Routing::RouteSet.new
      routes.draw(&block)
      include routes.url_helpers
      routes
    end
  end
end

class WithActiveStorageRoutesControllers < ActionController::Base
  test_routes do
    post "/rails/active_storage/direct_uploads" => "active_storage/direct_uploads#create", :as => :rails_direct_uploads
  end

  def url_options
    {host: "testtwo.host"}
  end
end

class FileFieldTest < ActionView::TestCase
  include FormProps::ActionViewExtensions::FormHelper

  setup :setup_test_fixture

  def test_file_field
    @post.splash = nil

    form_props(model: @post) do |f|
      f.file_field(:splash)
    end

    result = json.result!.strip
    expected = {
      "type" => "file",
      "name" => "post[splash]",
      "id" => "post_splash"
    }

    assert_equal(JSON.parse(result)["inputs"]["splash"], expected)
  end

  def test_file_field_with_options
    @post.splash = nil

    form_props(model: @post) do |f|
      f.file_field(:splash, class: "pix")
    end

    result = json.result!.strip
    expected = {
      "type" => "file",
      "name" => "post[splash]",
      "className" => "pix",
      "id" => "post_splash"
    }

    assert_equal(JSON.parse(result)["inputs"]["splash"], expected)
  end

  def test_file_field_tag_with_direct_upload_when_rails_direct_uploads_url_is_not_defined
    @post.splash = nil

    form_props(model: @post) do |f|
      f.file_field(:splash, class: "pix", direct_upload: true)
    end

    result = json.result!.strip
    expected = {
      "type" => "file",
      "name" => "post[splash]",
      "className" => "pix",
      "id" => "post_splash"
    }

    assert_equal(JSON.parse(result)["inputs"]["splash"], expected)
  end

  def test_file_field_tag_with_direct_upload_when_rails_direct_uploads_url_is_defined
    @post.splash = nil
    @controller = WithActiveStorageRoutesControllers.new

    form_props(model: @post) do |f|
      f.file_field(:splash, class: "pix", direct_upload: true)
    end

    result = json.result!.strip
    expected = {
      "type" => "file",
      "name" => "post[splash]",
      "className" => "pix",
      "data-direct-upload-url" => "http://testtwo.host/rails/active_storage/direct_uploads",
      "id" => "post_splash"
    }

    assert_equal(JSON.parse(result)["inputs"]["splash"], expected)
  end

  def test_file_field_tag_with_direct_upload_dont_mutate_arguments
    original_options = {class: "pix", direct_upload: true}

    form_props(model: @post) do |f|
      f.file_field(:splash, class: "pix", direct_upload: true)
    end

    json.result!.strip

    assert_equal({class: "pix", direct_upload: true}, original_options)
  end

  def test_file_field_has_no_size
    @post.splash = nil

    form_props(model: @post) do |f|
      f.file_field(:splash)
    end

    result = json.result!.strip

    assert_nil(JSON.parse(result)["inputs"]["splash"]["size"])
  end

  def test_file_field_with_multiple_behavior
    @post.splash = nil

    form_props(model: @post) do |f|
      f.file_field(:splash, multiple: true)
    end

    result = json.result!.strip
    expected = {
      "type" => "file",
      "name" => "post[splash][]",
      "id" => "post_splash",
      "multiple" => true
    }

    assert_equal(JSON.parse(result)["inputs"]["splash"], expected)
  end

  def test_file_field_with_multiple_behavior_and_explicit_name
    @post.splash = nil

    form_props(model: @post) do |f|
      f.file_field(:splash, multiple: true, name: "custom")
    end

    result = json.result!.strip
    expected = {
      "type" => "file",
      "id" => "post_splash",
      "multiple" => true,
      "name" => "custom"
    }

    assert_equal(JSON.parse(result)["inputs"]["splash"], expected)
  end
end
