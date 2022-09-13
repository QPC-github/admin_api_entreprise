require 'rails_helper'

RSpec.describe 'Simple pages', type: :feature, app: :api_particulier do
  describe 'home' do
    it 'works' do
      expect {
        visit '/compte'
      }.not_to raise_error

      expect(page).to have_content('API Particulier')
    end
  end
end
