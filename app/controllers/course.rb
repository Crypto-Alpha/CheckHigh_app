# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('course') do |routing|
      routing.on do
        # GET /course
        routing.get do
            view :course
        end
      end
    end

    route('courses') do |routing|
      routing.on do
        # GET /courses
        routing.get do
            view :courses
        end
      end
    end
  end
end
