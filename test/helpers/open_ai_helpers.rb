# frozen_string_literal: true

module OpenAiHelpers
  class StubAPIRequests
    extend MockHelpers
    CACHE_DIRECTORY = "#{Rails.root}/test/lib/open_ai/cached_api_responses"
    
    # Prevents hitting API while running tests
    def self.stub(client, data_file)
      mock_method(
        object: client,
        method: :post,
        mocked_result: cached_api_response(data_file)
      )
    end

    # Cache was generated from a real OpenAi request
    def self.cached_api_response(file_name)
      data = File.read("#{CACHE_DIRECTORY}/#{file_name}")
      JSON.parse(data)
    end
  end
end