# frozen_string_literal: true

require_relative 'form_base'

module CheckHigh
  module Form
    # create new shareboard form
    class NewShareBoard < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_shareboard.yml')

      params do
        required(:share_board_name).filled(max_size?: 256, format?: FILENAME_REGEX)
      end
    end
  end
end
