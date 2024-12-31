$LOAD_PATH << File.expand_path("lib", __dir__)
require "form_props/version"

Gem::Specification.new do |s|
  s.name = "form_props"
  s.version = FormProps::VERSION
  s.author = "Johny Ho"
  s.email = "johny@thoughtbot.com"
  s.license = "MIT"
  s.homepage = "https://github.com/thoughtbot/form_props/"
  s.summary = "Form props is a Rails form builder that renders form attributes in JSON"
  s.description = "Form props is a Rails form builder that renders form attributes in JSON"
  s.files = Dir["MIT-LICENSE", "README.md", "lib/**/*"]

  s.required_ruby_version = ">= 2.7"

  s.add_dependency "activesupport", ">= 7.0", "< 9.0"
  s.add_dependency "actionview", ">= 7.0", "< 9.0"
  s.add_dependency "props_template", ">= 0.30.0"
end
