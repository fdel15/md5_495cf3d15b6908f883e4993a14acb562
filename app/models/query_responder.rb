# frozen_string_literal: true

class QueryResponder
  OPENAI = 'open_ai'

  RESPONDERS = {
    OPENAI => OpenAi::AnswerQuery
  }

  def self.fetch_answer(query:, data_file:, responder: OPENAI, **options)
    question = Question.find_by_query(query)
    return question.answer if question

    responder = RESPONDERS.fetch(responder)
    answer = responder.fetch_answer(query: query, data_file: data_file, **options)
  end
end