ENV["RAILS_ENV"] ||= "test"
require_relative "../lib/form_props"
require "open3"
require "byebug"
require "props_template"

require "minitest"
require "minitest/autorun"
require "mocha/minitest"
require "rails"

Rails.backtrace_cleaner.remove_silencers!

require "active_model"

Continent = Struct.new(:id, :countries) do
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def errors
    Class.new {
      def [](field)
      end

      def empty?
        true
      end

      def count
        0
      end

      def full_messages
        []
      end
    }.new
  end

  def persisted?
    false
  end
end

Post = Struct.new(:id, :title, :author_name, :body, :category, :secret, :favs, :allow_comments, :splash, :persisted, :written_on, :cost, :admin, :author, :time_zone, :country, :weekday) do
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  extend ActiveModel::Translation

  alias_method :secret?, :secret
  alias_method :persisted?, :persisted

  def initialize(*args)
    super
    @persisted = false
  end

  attr_accessor :author
  def author_attributes=(attributes)
  end

  attr_accessor :comments, :comment_ids
  def comments_attributes=(attributes)
  end

  attr_accessor :tags
  def tags_attributes=(attributes)
  end

  attr_accessor :time_zone
end

class PostDelegator < Post
  def to_model
    PostDelegate.new
  end
end

class PostDelegate < Post
  def self.human_attribute_name(attribute)
    "Delegate #{super}"
  end

  def model_name
    ActiveModel::Name.new(self.class)
  end
end

class Comment
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :id
  attr_reader :post_id
  def initialize(id = nil, post_id = nil, body = nil)
    @id, @post_id, @body = id, post_id, body
  end

  def to_key
    id ? [id] : nil
  end

  def save
    @id = 1
    @post_id = 1
  end

  def persisted?
    @id.present?
  end

  def to_param
    @id&.to_s
  end

  def name
    @id.nil? ? "new #{self.class.name.downcase}" : "#{self.class.name.downcase} ##{@id}"
  end

  attr_accessor :relevances
  def relevances_attributes=(attributes)
  end

  attr_accessor :body
end

class Tag
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :id
  attr_reader :post_id
  def initialize(id = nil, post_id = nil)
    @id, @post_id = id, post_id
  end

  def to_key
    id ? [id] : nil
  end

  def save
    @id = 1
    @post_id = 1
  end

  def persisted?
    @id.present?
  end

  def to_param
    @id&.to_s
  end

  def value
    @id.nil? ? "new #{self.class.name.downcase}" : "#{self.class.name.downcase} ##{@id}"
  end

  attr_accessor :relevances
  def relevances_attributes=(attributes)
  end
end

class ActionView::TestCase
  def json
    @__json ||= Props::Template.new(self)
  end

  def render_js(str)
    str = <<-JS
      import * as React from 'react'
      import * as Server from 'react-dom/server'
      import Select from './components/Select'
      import Checkbox from './components/Checkbox'
      import CollectionCheckBoxes from './components/CollectionCheckBoxes'
      import CollectionRadioButtons from './components/CollectionRadioButtons'

      function out() {
        #{str}
      }

      console.log(Server.renderToString(out()))
    JS

    file = Tempfile.new(["test", ".js"], Dir.pwd)
    file.path
    file.write(str)
    file.close

    esbuild_cmd = "yarn run esbuild #{file.path} --bundle  --loader:.js=jsx --outfile=build/out.js"
    _stdout, stderr, status = Open3.capture3(esbuild_cmd)

    if !status.success?
      raise stderr
    end

    stdout, stderr, status = Open3.capture3("node build/out.js")

    if !status.success?
      raise stderr
    end

    stdout.strip
  end

  RecordForm = Struct.new(:to_model, keyword_init: true)
  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    resources :posts do
      resources :comments
    end

    resources :continents

    namespace :admin do
      resources :posts do
        resources :comments
      end
    end

    get "/foo", to: "controller#action"
    root to: "main#index"
  end

  include Routes.url_helpers

  def url_for(object)
    @url_for_options = object

    if object.is_a?(Hash) && object[:use_route].blank? && object[:controller].blank?
      object[:controller] = "main"
      object[:action] = "index"
      object[:host] = "http://localhost:3000"
    end

    super
  end
  VALID_HTML_ID = /^[A-Za-z][-_:.A-Za-z0-9]*$/ # see http://www.w3.org/TR/html4/types.html#type-name
  def setup_test_fixture
    @__json ||= Props::Template.new(self)
    # @user = User.new(email: "steve@example.com")
    ActionView::Helpers::FormTagHelper.default_enforce_utf8 = true
    ActionView::Helpers::FormHelper.form_with_generates_ids = true
    # Create "label" locale for testing I18n label helpers
    I18n.backend.store_translations "label",
      activemodel: {
        attributes: {
          post: {
            cost: "Total cost"
          },
          "post/language": {
            spanish: "Espanol"
          }
        }
      },
      helpers: {
        label: {
          post: {
            body: "Write entire text here",
            color: {
              red: "Rojo"
            },
            comments: {
              body: "Write body here"
            }
          },
          tag: {
            value: "Tag"
          },
          post_delegate: {
            title: "Delegate model_name title"
          }
        }
      }

    # Create "submit" locale for testing I18n submit helpers
    I18n.backend.store_translations "submit",
      helpers: {
        submit: {
          create: "Create %{model}",
          update: "Confirm %{model} changes",
          submit: "Save changes",
          another_post: {
            update: "Update your %{model}"
          },
          "blog/post": {
            update: "Update your %{model}"
          }
        }
      }

    I18n.backend.store_translations "placeholder",
      activemodel: {
        attributes: {
          post: {
            cost: "Total cost"
          },
          "post/cost": {
            uk: "Pounds"
          }
        }
      },
      helpers: {
        placeholder: {
          post: {
            title: "What is this about?",
            written_on: {
              spanish: "Escrito en"
            },
            comments: {
              body: "Write body here"
            }
          },
          post_delegate: {
            title: "Delegate model_name title"
          },
          tag: {
            value: "Tag"
          }
        }
      }

    @post = Post.new
    @comment = Comment.new
    @post.instance_eval do
      def errors
        Class.new {
          def [](field)
            (field == "author_name") ? ["can't be empty"] : []
          end

          def empty?
            false
          end

          def count
            1
          end

          def full_messages
            ["Author name can't be empty"]
          end
        }.new
      end

      def to_key
        [123]
      end

      def id
        0
      end

      def id_before_type_cast
        "omg"
      end

      def id_came_from_user?
        true
      end

      def to_param
        "123"
      end
    end

    @post.persisted = true
    @post.admin = true
    @post.title = "Hello World"
    @post.author_name = ""
    @post.splash = ""
    @post.body = "Back to the hill and over it again!"
    @post.secret = 1
    @post.favs = 1
    @post.written_on = Date.new(2004, 6, 15)

    @post.comments = []
    @post.comments << @comment

    @post.tags = []
    @post.tags << Tag.new

    @post_delegator = PostDelegator.new

    @post_delegator.title = "Hello World"

    @controller.singleton_class.include Routes.url_helpers
  end
end

module Blog
  def self.use_relative_model_naming?
    true
  end

  Post = Struct.new(:title, :id) do
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    def persisted?
      id.present?
    end
  end
end
