require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    @game_w_questions = FactoryGirl.create(:game_with_questions, user: user)
  end

  context 'Game Factory' do
    it 'Game.create_game! new correct game' do

      generate_questions(60)

      game = nil

      expect {
        game = Game.create_game_for_user!(user)

      }.to change(Game, :count).by(1).and(
          # GameQuestion.count +15
          change(GameQuestion, :count).by(15).and(
              # Game.count не должен измениться
              change(Question, :count).by(0)
          )
      )

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do

    it 'answer correct continues game' do

      level = @game_w_questions.current_level
      q = @game_w_questions.current_game_question
      expect(@game_w_questions.status).to eq(:in_progress)

      @game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(@game_w_questions.current_level).to eq(level + 1)

      expect(@game_w_questions.current_game_question).not_to eq(q)

      expect(@game_w_questions.status).to eq(:in_progress)
      expect(@game_w_questions.finished?).to be_falsey
    end

    it 'take_money! finishes the game' do
      # берем игру и отвечаем на текущий вопрос
      q = @game_w_questions.current_game_question
      @game_w_questions.answer_current_question!(q.correct_answer_key)

      # взяли деньги
      @game_w_questions.take_money!

      prize = @game_w_questions.prize
      expect(prize).to be > 0

      # проверяем что закончилась игра и пришли деньги игроку
      expect(@game_w_questions.status).to eq :money
      expect(@game_w_questions.finished?).to be_truthy
      expect(user.balance).to eq prize
    end

    context '.status' do
      # перед каждым тестом "завершаем игру"
      before(:each) do
        @game_w_questions.finished_at = Time.now
        expect(@game_w_questions.finished?).to be_truthy
      end

      it ':won' do
        @game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
        expect(@game_w_questions.status).to eq(:won)
      end

      it ':fail' do
        @game_w_questions.is_failed = true
        expect(@game_w_questions.status).to eq(:fail)
      end

      it ':timeout' do
        @game_w_questions.created_at = 1.hour.ago
        @game_w_questions.is_failed = true
        expect(@game_w_questions.status).to eq(:timeout)
      end

      it ':money' do
        expect(@game_w_questions.status).to eq(:money)
      end
    end

    describe '#current_game_question' do
      context 'when question is unanswered' do
        it 'returns current' do
          expect(@game_w_questions.current_game_question).to eq @game_w_questions.game_questions.first
        end
      end
    end

    describe '#previous_level' do
      context 'when previous level of complexity' do
        it 'returns game level' do
          expect(@game_w_questions.previous_level).to eq(-1)
        end
      end
    end

    context 'answer_current_question!' do
      let(:q) { @game_w_questions.current_game_question }
      it 'answer is correct' do
        expect(@game_w_questions.answer_current_question!(q.correct_answer_key)).to be true
        expect(@game_w_questions.finished?).to be false
        expect(@game_w_questions.status).to eq :in_progress
      end
      it 'answer is wrong' do
        expect(@game_w_questions.answer_current_question!('a')).to be false
        expect(@game_w_questions.finished?).to be true
        expect(@game_w_questions.status).to eq :fail

      end
      it 'question is last' do
        @game_w_questions.current_level = Question::QUESTION_LEVELS.max
        expect(@game_w_questions.answer_current_question!(q.correct_answer_key)).to be true
        expect(@game_w_questions.status).to eq :won
        expect(@game_w_questions.prize).to eq Game::PRIZES.last
      end
      it 'time_laps' do
        @game_w_questions.created_at = 1.hour.ago
        expect(@game_w_questions.answer_current_question!(q.correct_answer_key)).to be false
        expect(@game_w_questions.status).to eq :timeout
        expect(@game_w_questions.finished?).to be true
      end
    end
  end
end
