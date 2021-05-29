# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('assignment') do |routing|
      routing.on do
        # GET /assignment
        routing.get do
            view :assignment
        end
      end
    end
  end
end
