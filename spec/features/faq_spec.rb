require 'rails_helper'

RSpec.describe 'FAQ & Support', type: :feature do
  it 'displays entries' do
    visit faq_index_path

    expect(page).to have_css('.faq-entry', count: FAQEntry.all.count)
  end

  describe 'search', js: true do
    it 'works and highlight text' do
      visit faq_index_path

      expect(page).not_to have_css('.search-highlight')

      find('input.ais-SearchBox-input.fr-input').set(FAQEntry.all.first.question)

      expect(page).to have_css('.faq-entry', count: 1)
      expect(page).to have_css('.search-highlight')
    end
  end
end