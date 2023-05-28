# frozen_string_literal: true

module OpenAi
  class APIError < StandardError; end

  class MaxTokenError < StandardError
    attr_reader :token_count, :max_tokens
    def initialize(token_count, max_tokens)
      @token_count = token_count
      @max_tokens = max_tokens
      super(message)
    end

    def message
      "MaxTokenError: The maximum number of tokens per api request is #{max_tokens}. Your request will use #{token_count} tokens."
    end
  end
end