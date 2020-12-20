# frozen_string_literal: true

require 'faraday'
require 'awesome_print'
require 'base64'

module App
  class Handler
    POST_MESSAGE_URL = 'https://slack.com/api/chat.postMessage'
    BOT_USER_TOKEN = ENV['SLACK_BOT_USER_TOKEN']
    CHANNEL = '#nothing'

    class << self
      def process(event:, context:)
        type = event['headers']['x-github-event'] rescue 'unknown'
        body = event['isBase64Encoded'] ? Base64.decode64(event['body']) : event['body']
        body = JSON.parse(body) if body.is_a?(String)

        is_tag_created = body['ref_type'] == 'tag'

        response = Faraday.post(
          POST_MESSAGE_URL,
          { channel: CHANNEL,
            blocks: [
              {
                type: 'section',
                text: {
                  type: 'mrkdwn',
                  text: "something happened as #{type}"
                }
              },
              {
                type: 'section',
                text: {
                  type: 'mrkdwn',
                  text: is_tag_created ? "Created tag #{body['ref']}" : 'yok bi sey'
                }
              }
            ].to_json
          },
          { 'Authorization' => "Bearer #{BOT_USER_TOKEN}" }
        )

        JSON.parse(response.body)
      end
    end
  end
end
