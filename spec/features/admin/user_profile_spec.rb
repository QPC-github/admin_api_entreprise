require 'rails_helper'

RSpec.describe 'admin user profile', type: :feature do
  let(:admin) { create(:user, :admin) }

  before do
    login_as(admin)
  end

  subject do
    visit(admin_user_path(user))
  end

  describe 'user account details' do
    let(:user) { create(:user, :with_note) }

    it 'displays the email' do
      subject

      expect(page).to have_content(user.email)
    end

    it 'displays the context' do
      subject

      expect(page).to have_content(user.context)
    end

    it 'displays the note' do
      subject

      expect(page).to have_content(user.note)
    end

    it 'can update the note' do
      subject

      within('#user_details') do
        fill_in 'user_note', with: 'very note'
        click_button 'commit'

        expect(page).to have_content('very note')
        expect(user.reload.note).to eq('very note')
      end
    end

    it 'has a button to transfer the user account' do
      subject

      expect(page).to have_css('#transfer_account_button')
    end

    describe 'user account transfer' do
      let(:form_dom_id) { '#transfer_account' }
      let(:user) { create(:user, :with_jwt) }

      subject do
        visit(admin_user_path(user))
        within(form_dom_id) do
          fill_in 'email', with: email
          click_button
        end
      end

      context 'when no email address is provided' do
        let(:email) { '' }

        it_behaves_like :it_aborts_the_user_account_transfer
      end

      context 'when the provided email address is invalid' do
        let(:email) { 'not a valid email' }

        it_behaves_like :it_aborts_the_user_account_transfer
      end

      context 'when the provided email address is valid' do
        let(:email) { 'valid@email.com' }

        it_behaves_like :it_succeeds_the_user_account_transfer
      end

      describe 'with javascript actived', js: true do
        it 'works' do
          visit(admin_user_path(user))
          expect(page).not_to have_css(form_dom_id)
          click_on("transfer_account_button")

          expect(page).to have_css(form_dom_id)
        end
      end
    end
  end

  describe 'user tokens list' do
    let(:user) { create(:user, :with_jwt) }
    let(:jwt) { user.jwt_api_entreprise.take }

    it_behaves_like :it_displays_user_owned_token

    it 'has buttons to archive tokens' do
      subject

      expect{ click_button(dom_id(jwt, :archive_button)) }
        .to change { jwt.reload.archived? }.from(false).to(true)
    end

    it 'has button to blacklist tokens' do
      subject

      expect{ click_button(dom_id(jwt, :blacklist_button)) }
        .to change { jwt.reload.blacklisted? }.from(false).to(true)
    end

    it 'displays user archived tokens' do
      archived_jwt = create(:jwt_api_entreprise, :archived, user: user)
      subject

      expect(page).to have_css("input[value='#{archived_jwt.rehash}']")
    end

    it 'displays user blacklisted tokens' do
      blacklisted_jwt = create(:jwt_api_entreprise, :blacklisted, user: user)
      subject

      expect(page).to have_css("input[value='#{blacklisted_jwt.rehash}']")
    end

    describe 'magic token creation' do
      let(:user) { create(:user, :with_jwt) }
      let(:token) { user.jwt_api_entreprise.take }

      subject do
        visit(admin_user_path(user))
        within("#" + dom_id(token, :magic_link)) do
          fill_in 'email', with: email
          click_button
        end
      end

      context 'when the email address is valid' do
        let(:email) { 'valid@email.com' }

        it_behaves_like :it_creates_a_magic_link

        it 'redirects to the admin user details page' do
          subject

          expect(page).to have_current_path(admin_user_path(user))
        end

      end

      context 'when the email address is invalid' do
        let(:email) { 'not an email' }

        it_behaves_like :it_aborts_magic_link

        it 'redirects to the admin user details page' do
          subject

          expect(page).to have_current_path(admin_user_path(user))
        end
      end

      describe 'with javascript actived', js: true do
        it 'works' do
          visit admin_user_path(user)
          expect(page).not_to have_css('#' + dom_id(token, :magic_link))
          click_on dom_id(token, :modal_button)
          expect(page).to have_css('#' + dom_id(token, :magic_link))
        end
      end
    end
  end
end