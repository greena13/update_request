$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "update_request/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "update_request"
  s.version     = UpdateRequest::VERSION
  s.authors     = ["Aleck Greenham"]
  s.email       = ["greenhama13@gmail.com"]
  s.homepage    = "https://github.com/greena13/update_request"
  s.summary     = "Rails engine for approvable resource updates"
  s.description = "Rails engine for allowing approvable resource updates that support file uploads"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4", '>= 4.2.4'
  s.add_dependency "paperclip", '>= 4.3.0'

  s.add_development_dependency "sqlite3", "~> 0"
end
