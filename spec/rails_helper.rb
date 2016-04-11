ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'factory_girl_rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  options = {
    js_errors: true,
    timeout: 120,
    debug: false,
    phantomjs_options: ['--load-images=no', '--disk-cache=false'],
    inspector: true,
  }
  Capybara::Poltergeist::Driver.new app, options
end
Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/factories"

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.render_views
  config.order = :random

  config.include FactoryGirl::Syntax::Methods

  config.before(:each) { DatabaseCleaner.strategy = :transaction }
  config.before(:each, js: true) { DatabaseCleaner.strategy = :truncation }
  config.before(:each) { DatabaseCleaner.start }
  config.after(:each) { DatabaseCleaner.clean }
end
