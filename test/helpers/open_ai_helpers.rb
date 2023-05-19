# frozen_string_literal: true

module OpenAiHelpers
  class Embeddings
    extend MockHelpers
    
    # Prevents hitting API while running tests
    def self.mock_embeddings_request(client)
      mock_method(
        object: client,
        method: :post,
        mocked_result: cached_api_response
      )
    end

    # Cache was generated from a real OpenAi request
    def self.cached_api_response
      data = File.read("#{Rails.root}/test/lib/open_ai/cached_api_responses/embedding.json")
      JSON.parse(data)
    end
  end
end