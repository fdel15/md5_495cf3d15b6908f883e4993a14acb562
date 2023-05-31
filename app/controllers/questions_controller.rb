class QuestionsController < ApplicationController
  def create
    query = params[:question]
    data_file = params[:data_file]
    answer = QueryResponder.fetch_answer(query: query, data_file: data_file)
    render json: answer.to_json
  end
end
