require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  context 'watching user page' do
    before(:each) do
      assign(:user, FactoryGirl.build_stubbed(:user, name: 'Mariya'))
      assign(:games, [FactoryGirl.build_stubbed(:game, id: 1, created_at: Time.now, current_level: 7)])

      render
    end

    it 'renders user name' do
      expect(rendered).to match 'Mariya'
    end

    it 'does not link button for changing user data' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end

    it 'renders fragments of game' do
      assert_template partial: 'users/_game'
    end
  end

  context 'user watching own page' do
    before(:each) do
      user = FactoryGirl.create(:user, name: 'Mariya')
      sign_in user
      assign(:user, user)

      assign(:games, [FactoryGirl.build_stubbed(:game, id: 1, created_at: Time.now, current_level: 7)])

      render
    end

    it 'renders user name' do
      expect(rendered).to match 'Mariya'
    end

    it 'renders link button for changing user data' do
      expect(rendered).to match 'Сменить имя и пароль'
    end

    it 'renders fragments of game' do
      assert_template partial: 'users/_game'
    end
  end
end
