require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  should validate_presence_of(:text)
  should validate_presence_of(:user)
  should validate_presence_of(:question)

  should belong_to(:user)
  should belong_to(:question)
  should have_many(:votes)

  context "Answer class" do
    should "be able to get answers in order by number of votes and created at" do
      Timecop.scale(3600) do
        questions(:one).answers.delete_all
        answer1 = Answer.create!(user: users(:one), question: questions(:one),
                                 text: "answer1")
        answer2 = Answer.create!(user: users(:two), question: questions(:one),
                                 text: "answer2")
        answer3 = Answer.create!(user: users(:one), question: questions(:one),
                                 text: "answer3")
        answer4 = Answer.create!(user: users(:one), question: questions(:one),
                                 text: "answer4")
        Vote.create!(voteable: answer2, user: users(:one), value: 1)
        Vote.create!(voteable: answer3, user: users(:two), value: -1)

        assert_equal [answer2, answer1, answer4, answer3],
                     questions(:one).reload.answers.order_by_votes
      end
    end
  end

  context "an answer" do
    should "only allow one chosen answer per question" do
      # In order to make sure only one answer can be chosen per question
      # I need to set a current answer for a question to be chosen.
      # I am using an answer from the fixtures.
      chosen_answer = answers(:one_for_question_one)
      chosen_answer.update(chosen: true)

      # I need to set my answer model under test to have the same question
      # as the answer from the fixtures, so that I can test that two answers
      # for the same question cannot be chosen.
      new_answer = Answer.new
      new_answer.question = chosen_answer.question

      # Choose a second answer for the question.
      new_answer.chosen = true

      assert new_answer.invalid?, "Only one answer can be chosen per question"
      assert_not_empty new_answer.errors[:chosen]
    end

    should "allow it to be the first chosen answer" do
      question = questions(:one)
      answer = question.answers.build(chosen: true)

      answer.valid?
      assert_empty answer.errors[:chosen]
    end

    should "award its user 100 points when chosen" do
      question = questions(:one)
      answer = question.answers.first
      refute answer.chosen?

      assert_difference 'answer.user.score', 100 do
        answer.update(chosen: true)
      end
    end

    should "know its own score" do
      answer = answers(:one_for_question_one)
      voter1 = users(:chet)
      voter2 = users(:voter)
      answer.votes.create!(value: 1, user: voter1)
      answer.votes.create!(value: 1, user: voter2)

      assert_equal 2, answer.score
    end
  end
end
