ENV["RAILS_ENV"] ||= "test"

require "spec_helper"

# Add this to load your dummy app's environment file. This file will require
# the application.rb file in the dummy directory, and initialise the dummy app.
# Very simple, now you have your dummy application in memory for your specs.
require File.expand_path("../dummy/config/environment", __FILE__)

require "rspec/rails"

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

end
