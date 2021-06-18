# frozen_string_literal: true

require_relative 'account'
require_relative 'assignment'

module CheckHigh
  # Behaviors of the currently logged in account
  class Course
    attr_reader :id, :course_name, :links, # basic info
                :owner, :assignments, :policies # full details

    def initialize(course_info)
      process_attributes(course_info['attributes'])
      process_relationships(course_info['relationships'])
      process_policies(course_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @course_name = attributes['course_name']
      @links = attributes['links']['href']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @assignments = process_assignments(relationships['assignments'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end

    def process_assignments(assignments_info)
      return nil unless assignments_info

      assignments_info.map { |assi_info| Assignment.new(assi_info) }
    end
  end
end
