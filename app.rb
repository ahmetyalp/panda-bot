# frozen_string_literal: true

require_relative 'lib/slack.rb'
require_relative 'lib/github_event.rb'

module App
  class Handler
    class << self
      def process(event:, context:)
        parsed_event = Github::Event.new(event)

        messages = case parsed_event.type
        when 'create' then Github.handle_create(parsed_event.body)
        when 'status' then Github.handle_ci(parsed_event.body)
        end

        Slack.send(messages) unless messages.nil?
        { statusCode: 200, body: 'OK' }
      rescue StandardError => e
        Slack.send(["Error:", e.to_s.gsub(GitHelper::GIT_USER_PASSWORD, '<protected>')]) rescue nil

        { statusCode: 500 , body: 'err' }
      end
    end
  end
end
