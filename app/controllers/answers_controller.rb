class AnswersController < ApplicationController
  before_action :authenticate

  def create
    @question = Question.find(params[:question_id])
    @answers = @question.answers.order_by_votes
    @answer = @question.answers.build(answer_params)
    @answer.user = current_user

    if @answer.save
      redirect_to @question
    else
      render "questions/show"
    end
  end

  def vote
    @answer = Answer.find(params[:id])
    @vote = @answer.votes.build(user: current_user, value: params[:value])
    respond_to do |format|
      format.html do
        if @vote.save
          redirect_to @answer.question, success: "Your vote was recorded."
        else
          redirect_to @answer.question, error: "There was a problem saving your vote."
        end
      end
      format.js do
        if @vote.save
          render :create, status: :created
        end
      end
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:text)
  end
end
