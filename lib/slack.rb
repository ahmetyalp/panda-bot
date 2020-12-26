# frozen_string_literal: true

require 'faraday'

module Slack
  POST_MESSAGE_URL = 'https://slack.com/api/chat.postMessage'
  BOT_USER_TOKEN = ENV['SLACK_BOT_USER_TOKEN']
  DEFAULT_CHANNEL = '#nothing'

  class << self
    def send(messages, channel = DEFAULT_CHANNEL)
      Faraday.post(
        POST_MESSAGE_URL,
        {
          channel: channel,
          blocks: build_blocks(messages)
        },
        { 'Authorization' => "Bearer #{BOT_USER_TOKEN}" }
      )
    end

    private

    def build_blocks(messages)
      messages.map do |message|
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: message
          }
        }
      end.to_json
    end
  end
end
