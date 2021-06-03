# frozen_string_literal: true

require_relative 'share_board'

module CheckHigh
  # Behaviors of the currently logged in account
  class ShareBoards
    attr_reader :all

    def initialize(shareboards_list)
      return @all = [] if shareboards_list.length.zero?
      @all = shareboards_list.map do |share_board|
        ShareBoard.new(share_board)
      end
    end
  end
end