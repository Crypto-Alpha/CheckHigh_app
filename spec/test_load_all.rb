# frozen_string_literal: true

require_relative '../require_app'
require_app

# run pry -r <path/to/this/file>

def app
  CheckHigh::App
end

unless app.environment == :production
  require 'rack/test'
  include Rack::Test::Methods # rubocop:disable Style/MixinUsage
end
