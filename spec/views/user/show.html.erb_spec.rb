require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  context 'watching user page' do
    before(:each) do
      @games = [FactoryBot.build_stubbed(:game, id: 1, created_at: Time.now, current_level: 7)]
      assign(:user, FactoryBot.build_stubbed(:user, name: 'Mariya'))
      assign(:games, @games)
      render
    end

    it 'renders user name' do
      expect(rendered).to match 'Mariya'
    end

    it 'does not link button for changing user data' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end

    it 'renders fragments of game' do
      assert_template partial: 'users/_game', count: @games.count
    end
  end

  context 'user watching own page' do
    before(:each) do
      user = FactoryBot.create(:user, name: 'Mariya')
      @games = [FactoryBot.build_stubbed(:game, id: 1, created_at: Time.now, current_level: 7)]
      allow(controller).to receive(:current_user) { user }
      assign(:user, user)
      assign(:games, @games)

      render
    end

    it 'renders user name' do
      expect(rendered).to match 'Mariya'
    end

    it 'renders link button for changing user data' do
      expect(rendered).to match 'Сменить имя и пароль'
    end

    it 'renders fragments of game' do
      assert_template partial: 'users/_game', count: @games.count
    end
  end
end
