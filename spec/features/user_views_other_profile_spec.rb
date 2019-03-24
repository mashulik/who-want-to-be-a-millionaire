require 'rails_helper'

RSpec.feature 'USER views other profile', type: :feature do

  let(:user) { FactoryBot.create :user, name: 'Larisa' }
  let(:other_user) { FactoryBot.create :user, name: 'Olga' }
  let(:games) do
    [
      FactoryGirl.create(:game, id: 3, user: other_user, prize: 0, current_level: 13,
      created_at: Time.parse('2019-03-24 18:41')),
      FactoryGirl.create(:game, id: 2, user: other_user, prize: 1000, current_level: 11,
      created_at: Time.parse('2019-03-24 18:38'))
    ]
  end

  before(:each) do
    login_as user
  end

  scenario 'successfully' do
    visit '/'

    click_link 'Olga'

    expect(page).to have_content 'Olga'
    expect(page).to have_content 'Сменить имя и пароль'

    expect(page).to have_content '3'
    expect(page).to have_content 'проигрыш'
    expect(page).to have_content '24 марта, 18:41'
    expect(page).to have_content '13'
    expect(page).to have_content '0 ₽'

    expect(page).to have_content '2'
    expect(page).to have_content 'проигрыш'
    expect(page).to have_content '24 марта, 18:38'
    expect(page).to have_content '11'
    expect(page).to have_content '1000 ₽'

  end
end