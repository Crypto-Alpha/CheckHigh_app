# frozen_string_literal: true

require_relative 'share_board'

module CheckHigh
  # Behaviors of the currently logged in account
  class ShareBoard
    attr_reader :id, :share_board_name, :links

    def initialize(share_board_info)
      @id = share_board_info['attributes']['id']
      @share_board_name = share_board_info['attributes']['share_board_name']
      @links = share_board_info['attributes']['links']['href']
    end
  end
end