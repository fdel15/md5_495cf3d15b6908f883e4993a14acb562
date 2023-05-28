require "test_helper"

require_relative "../../helpers/open_ai_helpers"

class TestChat < ActiveSupport::TestCase
  def setup
    @chat_gpt_3_5_turbo = OpenAi::Chat.new(model: 'gpt-3.5-turbo')
  end

  def test_max_prompt_tokens
    random_int = rand(1..1000)
    mock_method(
      object: @chat_gpt_3_5_turbo,
      method: :max_tokens,
      mocked_result: random_int
    )
    max_prompt_tokens = @chat_gpt_3_5_turbo.max_prompt_tokens
    expected = random_int / 2
    assert_equal(max_prompt_tokens, expected, "Is expected to be half of the objects max tokens")
  end

  def test_create_validates_prompt_tokens_count
    api_client = @chat_gpt_3_5_turbo.client

    # prevents pinging API incase the validation fails
    OpenAiHelpers::StubAPIRequests.stub(api_client, 'chat.json')

    query = Faker::Lorem.sentence
    content = Array.new(5) { Faker::Lorem.sentence }

    mock_method(
      object: @chat_gpt_3_5_turbo,
      method: :max_prompt_tokens,
      mocked_result: 0
    )

    assert_raises(OpenAi::MaxTokenError) do
      @chat_gpt_3_5_turbo.create(query: query, content: content)
    end
  end

  def test_create_returns_message
    api_client = @chat_gpt_3_5_turbo.client

    OpenAiHelpers::StubAPIRequests.stub(api_client, 'chat.json')

    query = Faker::Lorem.sentence
    content = Array.new(5) { Faker::Lorem.sentence }

    message = @chat_gpt_3_5_turbo.create(query: query, content: content)

    assert(message.is_a?(String))

    # From cached API response in chat.json that we stubbed earlier
    # This is brittle and can probably be improved
    expected = "The Voldemort Ravenclaws won the Quidditch Cup in 2023."

    assert_equal(message, expected)
  end
end
