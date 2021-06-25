# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'simplecov'
SimpleCov.start

require_relative 'test_load_all'

API_URL = app.config.API_URL
