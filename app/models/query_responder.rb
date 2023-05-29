# frozen_string_literal: true

##
# This class is responsible for taking a query from the user and returning
# the answer
##
class QueryResponder
  OPENAI = 'open_ai'

  RESPONDERS = {
    OPENAI => OpenAi::AnswerQuery
  }

  def self.fetch_answer(query:, data_file:, responder: OPENAI, **options)
    question = Question.find_by_query(query)

    if question
      question.increment_number_of_times_asked
      return question.answer_text
    end

    responder = RESPONDERS.fetch(responder)
    answer_text = responder.fetch_answer(query: query, data_file: data_file, **options)
    Question.create(query_text: query, answer_text: answer_text)
    answer_text
  end
end