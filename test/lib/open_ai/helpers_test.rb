# frozen_string_literal: true

require "test_helper"

class TestCosine < ActiveSupport::TestCase
  include OpenAiHelpers

  def test_calculate_tokens_cl100k_base
    # expected token counts were calculated using OpenAis tokenizer python package
    # https://platform.openai.com/docs/guides/embeddings/how-can-i-tell-how-many-tokens-a-string-has-before-i-embed-it

    tokenizer = 'cl100k_base'

    short_string = "beatae"
    short_string_token_count = calculate_tokens(short_string, tokenizer)
    short_string_expected_token_count = 3

    assert_equal(short_string_expected_token_count, short_string_token_count)

    long_string = "Excepturi voluptatem sed. Odit cupiditate hic. Atque amet molestiae."
    long_string_token_count = calculate_tokens(long_string, tokenizer)
    long_string_expected_token_count = 18

    assert_equal(long_string_expected_token_count, long_string_token_count)
  end
end