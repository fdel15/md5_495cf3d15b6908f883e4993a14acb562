# frozen_string_literal: true

##
# Common methods that can be included in multiple OpenAi libraries
##
module OpenAiHelpers
  def calculate_tokens(text, tokenizer)
    encoder = Tiktoken.get_encoding(tokenizer)
    encoder.encode(text).length
  end
end
