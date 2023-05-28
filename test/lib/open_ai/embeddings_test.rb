# frozen_string_literal: true

require "test_helper"
require_relative "../../helpers/open_ai_helpers"

class TestOpenAiEmbeddings < ActiveSupport::TestCase
  def setup
    @embedder_ada_002 = OpenAi::Embeddings.new(
      model: 'text-embedding-ada-002',
      tokenizer: 'cl100k_base'
    )
  end

  def test_create_raises_max_token_error
    mock_method(
      object: @embedder_ada_002,
      method: :max_input_tokens,
      mocked_result: 0
    )

    assert_equal(@embedder_ada_002.max_input_tokens, 0)
    
    assert_raises(OpenAi::MaxTokenError) do
      @embedder_ada_002.create(Faker::Lorem.word)
    end
  end

  def test_create_returns_embeddings
    OpenAiHelpers::Embeddings.mock_embeddings_request(@embedder_ada_002.client)

    text = Faker::Lorem.word
    output_dimensions = @embedder_ada_002.output_dimensions

    result = @embedder_ada_002.create(text)

    assert result.is_a?(Array), "Result should be an array of embeddings"

    assert_equal(result.length, output_dimensions, "Number of embeddings should equal output dimensions for the model")

    sample = result.sample

    assert sample.is_a?(Float), "Result should be a vector (list) of floating point numbers"

    assert between_negative_1_and_1(sample), "Floating point numbers should be between -1 and 1"
  end

  def between_negative_1_and_1(float)
    float > -1 && float < 1
  end
end

