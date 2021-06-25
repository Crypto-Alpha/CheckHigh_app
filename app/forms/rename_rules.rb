# frozen_string_literal: true

require_relative 'form_base'

module CheckHigh
  module Form
    # rename form
    class RenameRules < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/rename_rules.yml')

      params do
        required(:new_name).filled(max_size?: 256, format?: FILENAME_REGEX)
        # not knowing what to test
      end
    end
  end
end
