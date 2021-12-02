require 'rails_helper'

RSpec.describe 'admin token index', type: :feature do
  let(:admin) { create(:user, :admin) }

  let!(:tokens) { create_list(:jwt_api_entreprise, 3) }
  let(:random_token) { tokens.shuffle.first }
  let!(:active_token) { create(:jwt_api_entreprise, archived: false, blacklisted: false) }
  let!(:archived_token) { create(:jwt_api_entreprise, archived: true) }
  let!(:blacklisted_token) { create(:jwt_api_entreprise, blacklisted: true) }

  before do
    login_as(admin)
    visit(admin_tokens_path)
  end

  it 'displays tokens in a table with one row per user' do
    expect(page.all(".token_summary").size).to eq(JwtAPIEntreprise.count)
  end

  it 'created_at' do
    date = random_token.created_at.strftime('%d/%m/%Y')

    within('#' << dom_id(random_token)) do
      expect(page).to have_content(date)
    end
  end

  it 'subject' do
    within('#' << dom_id(random_token)) do

      expect(page).to have_content(random_token.displayed_subject)
    end
  end

  it 'clicking subject redirects to user profile' do
    within('#' << dom_id(random_token)) do
      click_link(random_token.displayed_subject)

      expect(page.current_path).to eq(admin_user_path(random_token.user))
    end
  end

  it 'exp' do
    date_with_hour = Time.zone.at(random_token.exp).strftime('%d/%m/%Y à %H:%M:%S')

    within('#' << dom_id(random_token)) do
      expect(page).to have_content(date_with_hour)
    end
  end

  it 'blacklisted status as Oui for blacklisted token' do
    within('#' << dom_id(blacklisted_token)) do
      expect(page).to have_content('Oui')
    end
  end

  it 'blacklisted status as Non for not blacklisted token' do
    within('#' << dom_id(active_token)) do
      expect(page).to have_content('Non')
    end
  end

  it 'archived status as Oui for archived token' do
    within('#' << dom_id(archived_token)) do
      expect(page).to have_content('Oui')
    end
  end

  it 'archived status as Non for not archived token' do
    within('#' << dom_id(active_token)) do
      expect(page).to have_content('Non')
    end
  end
end