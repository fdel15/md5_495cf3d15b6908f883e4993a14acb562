# frozen_string_literal: true

##
# Encapsulates how we interact with OpenAI API
##
module OpenAi
  class Client
    include HTTParty

    API_KEY = ENV['OPENAI_API_KEY']
    API_BASE_URL = 'https://api.openai.com/v1/'

    # base uri to be used for each request
    base_uri API_BASE_URL

    # HTTP headers to be used for each request
    headers 'Content-Type' => 'application/json'
    headers 'Authorization' => "Bearer #{API_KEY}"

    # Automatically parse response data as json
    format :json

    def get(endpoint, params = {})
      options = { query: params }
      response = self.class.get(endpoint, options)
      handle_response(response)
    end

    def post(endpoint, body = {})
      options = { body: body.to_json }
      response = self.class.post(endpoint, options)
      handle_response(response)
    end

    private

    def handle_response(response)
      if response.success?
        response.parsed_response
      else
        error_code = response.code
        message = response.response.message
        raise OpenAi::APIError.new "Error: #{error_code} #{message}"
      end
    end
  end
end
