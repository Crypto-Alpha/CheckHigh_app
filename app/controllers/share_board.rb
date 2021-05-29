# frozen_string_literal: true

require 'roda'
require_relative './app'

module CheckHigh
  # Web controller for CheckHigh API
  class App < Roda
    route('share_board') do |routing|
      routing.on do
        # GET /share_board
        routing.get do
            view :share_board
        end
      end
    end
    route('share_boards') do |routing|
      routing.on do
        # GET /share_boards
        routing.get do
            view :share_boards
        end
      end
    end
  end
end
