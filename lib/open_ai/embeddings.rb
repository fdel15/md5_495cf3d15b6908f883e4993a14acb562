# frozen_string_literal: true

##
# Generate Embeddings using OpenAi
# https://platform.openai.com/docs/guides/embeddings/embeddings
##

module OpenAi
  class Embeddings
    # https://platform.openai.com/docs/guides/embeddings/embedding-models
    DEFAULT_MODEL = 'text-embedding-ada-002'
    EMBEDDING_MODEL = ENV['OPEN_AI_EMBEDDING_MODEL'] || DEFAULT_MODEL
    
    DEFAULT_TOKENIZER = 'cl100k_base'
    TOKENIZER = ENV['OPEN_AI_EMBEDDING_TOKENIZER'] || DEFAULT_TOKENIZER

    # Refer to Opean_AI documentation for max tokens per tokenizer
    # https://platform.openai.com/docs/guides/embeddings/what-are-embeddings
    # This variable is provided to try new tokenizers without requiring changing code
    DEFAULT_MAX_TOKENS = ENV['OPEN_AI_EMBEDDING_DEFAULT_MAX_TOKENS'].to_i

    MAX_TOKEN_INPUTS = {
      "cl100k_base" => 8191,
      "gpt2" => 2046,
      "gpt3" => 2046
    }

    # https://platform.openai.com/docs/guides/embeddings/second-generation-models
    OUTPUT_DIMENSIONS = {
      "text-embedding-ada-002" => 1536,
      "Ada" => 1024, # not recommended to use this model
      "Babbage" => 2048, # not recommended to use this model
      "Curie" => 4096, # not recommended to use this model
      "Davinci" => 12288 # not recommended to use this model
    }

    DEFAULT_OUTPUT_DIMENSIONS = ENV['OPEN_AI_EMBEDDING_DEFAULT_OUTPUT_DIMENSIONS'].to_i

    attr_reader :client, :model, :tokenizer, :endpoint
    def initialize(model: EMBEDDING_MODEL, tokenizer: TOKENIZER)
      @client = OpenAi::Client.new
      @model = model
      @tokenizer = tokenizer
      @endpoint = '/embeddings'
    end

    def calculate_tokens(text)
      encoder = Tiktoken.get_encoding(tokenizer)
      encoder.encode(text).length
    end

    def create(text)
      validate_text(text)

      body = {
        input: text,
        model: model
      }

      data = client.post(endpoint, body)
      extract_embeddings_from_api_response(data)
    end

    def max_input_tokens
      MAX_TOKEN_INPUTS.fetch(tokenizer, DEFAULT_MAX_TOKENS)
    end

    def output_dimensions
      OUTPUT_DIMENSIONS.fetch(model, DEFAULT_OUTPUT_DIMENSIONS)
    end

    private

    def extract_embeddings_from_api_response(response)
      response['data'].first['embedding']
    end

    def validate_text(text)
      token_count = calculate_tokens(text)
      raise MaxTokenError.new(token_count, max_input_tokens) if token_count > max_input_tokens
    end
  end
end
