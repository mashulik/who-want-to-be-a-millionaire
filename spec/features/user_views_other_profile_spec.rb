require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.feature 'USER views other profile', type: :feature do

  let(:user) { FactoryBot.create :user, name: 'Larisa' }
  let(:other_user) { FactoryBot.create :user, name: 'Olga' }
  let(:first_game) do
    FactoryBot.create(:game, user: other_user, current_level: 13, fifty_fifty_used: true)
  end
  let(:second_game) do
    FactoryBot.create(:game, user: other_user, prize: 1000, current_level: 11)
  end
  let!(:games) { [first_game, second_game] }

  before(:each) do
    login_as user
  end

  scenario 'successfully', focus: true do
    visit '/'

    click_link 'Olga'

    expect(page).to have_content 'Olga'
    expect(page).to have_selector 'table.games-table'
    expect(page).to have_selector 'tr.text-center', count: games.count
    expect(page).to_not have_link 'Сменить имя и пароль', href: edit_user_registration_path(other_user)

    expect(page).to have_content first_game.id
    expect(page).to have_content I18n.t("game_statuses.#{first_game.status}")
    expect(page).to have_content I18n.l(first_game.created_at, format: :short)
    expect(page).to have_content first_game.current_level
    expect(page).to have_content number_to_currency(first_game.prize)

    expect(page).to have_content second_game.id
    expect(page).to have_content I18n.t("game_statuses.#{second_game.status}")
    expect(page).to have_content I18n.l(second_game.created_at, format: :short)
    expect(page).to have_content second_game.current_level
    expect(page).to have_content number_to_currency(second_game.prize)
  end
end
