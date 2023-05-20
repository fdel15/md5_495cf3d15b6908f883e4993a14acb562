class QuestionsController < ApplicationController
  def create
    answer = SecureRandom.hex.to_json 
    render json: answer
  end
end
