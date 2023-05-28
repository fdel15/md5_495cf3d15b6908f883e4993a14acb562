# frozen_string_literal: true

require_relative 'helpers'

##
# Generate Chat messages using OpenAi
# https://platform.openai.com/docs/guides/chat
##
module OpenAi

  class Chat
    include OpenAiHelpers
    # https://platform.openai.com/docs/guides/embeddings/embedding-models
    DEFAULT_MODEL = 'gpt-3.5-turbo'
    CHAT_MODEL = ENV['OPEN_AI_CHAT_MODEL'] || DEFAULT_MODEL
    
    # Models and their tokeniers can be found here
    # https://github.com/openai/openai-cookbook/blob/main/examples/How_to_count_tokens_with_tiktoken.ipynb
    DEFAULT_TOKENIZER = 'cl100k_base'
    TOKENIZER = ENV['OPEN_AI_CHAT_TOKENIZER'] || DEFAULT_TOKENIZER

    # https://platform.openai.com/docs/models/gpt-4
    MODEL_MAX_TOKENS = {
      "gpt-3.5-turbo" => 4096,
      "gpt-4" => 8192,
      "text-davinci-003" => 4097
    }

    ##
    # What sampling temperature to use, between 0 and 2. 
    # Higher values like 0.8 will make the output more random, while lower values
    # like 0.2 will make it more focused and deterministic
    #
    # https://platform.openai.com/docs/api-reference/chat/create#chat/create-temperature
    ##
    TEMPERATURE = ENV['OPEN_AI_CHAT_TEMPERATURE'] || 0

    ##
    # You can limit the maximum cost per request by configuring this ENV variable
    ##
    MAX_TOKENS_OVERRIDE = ENV['OPEN_AI_CHAT_MAX_TOKENS_OVERRIDE']

    attr_reader :client, :model, :endpoint, :temperature, :tokenizer
    def initialize(model: CHAT_MODEL, tokenizer: TOKENIZER, temperature: TEMPERATURE)
      @client = OpenAi::Client.new
      @model = model
      @tokenizer = tokenizer
      @temperature = temperature
      @endpoint = '/chat/completions'
    end

    def create(query:, content: [], system_msgs: [])
      token_strings = [query, content, system_msgs].flatten
      validate_prompt(token_strings)

      prompt = create_prompt(query: query, content: content)

      system_messages = create_messages(system_msgs, role: 'system')
      user_messages = create_message(content: prompt, role: 'user')

      messages = [system_messages, user_messages].flatten

      body = {
        messages: messages,
        model: model,
        temperature: temperature,
        max_tokens: max_tokens
      }

      data = client.post(endpoint, body)
      extract_message_from_api_response(data)
    end

    ##
    # Both input tokens in our request (prompt) to OpenAI API and the output 
    # tokens in the response count towards the number of tokens used per request
    #
    # Very long conversations are more likely to receive incomplete replies
    # e.g. if max_tokens is 4096 tokens, and 4090 tokens are used for the prompt
    #      then the response will be cut off at 6 tokens
    #
    # By limiting the amount of tokens in the prompt, we should be able to
    # prevent the frequency of incomplete replies
    #
    # https://platform.openai.com/docs/guides/chat/introduction
    ##
    def max_prompt_tokens
      (max_tokens / 2).to_i # One half has been chosen arbitrarily
    end

    private

    def max_tokens
      return MAX_TOKENS_OVERRIDE.to_i if MAX_TOKENS_OVERRIDE

      MODEL_MAX_TOKENS.fetch(model, 0)
    end

    def validate_prompt(string_array)
      token_count = 0
      string_array.each do |string|
        token_count += calculate_tokens(string, tokenizer)
        raise MaxTokenError.new(token_count, max_prompt_tokens) if token_count > max_prompt_tokens
      end
    end

    # Inspired by the below example from OpenAI cookbook
    # https://github.com/openai/openai-cookbook/blob/main/examples/Question_answering_using_embeddings.ipynb
    def create_prompt(query:, content: [])
      return query if content.empty?

      prompt = <<~PROMPT
        Use the below data to answer the subsequent question. If the answer cannot be found, write "I don't know."

        Data:
        """
        #{content.join("\n")}
        """

        Question: #{query}
      PROMPT

      prompt
    end

    def create_messages(message_array, role:)
      message_array.map do |text|
        create_message(content: text, role: role)
      end
    end

    def create_message(content:, role:)
      {"role": "#{role}", "content": "#{content}"}
    end

    def extract_message_from_api_response(response)
      response['choices'].first['message']['content']
    end
  end
end
