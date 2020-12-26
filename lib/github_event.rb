# frozen_string_literal: true

require 'base64'

require_relative 'git.rb'

module Github
  FINAL_STATES = ['success', 'failure'].freeze

  class Event
    def initialize(event)
      self.lambda_event = event
    end

    def body
      @body ||= begin
        body = lambda_event['isBase64Encoded'] ? Base64.decode64(lambda_event['body']) : lambda_event['body']

        body.is_a?(String) ? JSON.parse(body) : body
      end
    end

    def type
      @type ||= lambda_event['headers']['x-github-event']
    end

    private

    attr_accessor :lambda_event
  end

  class << self
    def handle_create(body)
      ref_type = body['ref_type']
      GitHelper.bump_and_push(body['repository']['name'], body['ref']) if ref_type == 'tag'

      ["Created #{body['ref_type']}: #{body['ref']}"]
    end

    def handle_ci(body)
      build_ci_message(body, body['state'])
    end

    private

    def build_ci_message(body, state)
      return unless FINAL_STATES.include?(state)

      ["CI #{state} for branch #{body['repository']['full_name']} -- #{body['branches'][0]&.dig('name')}"]
    end
  end
end
