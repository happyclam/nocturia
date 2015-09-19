require 'rails_helper'

RSpec.describe "Statics", type: :request do
  describe "GET /statics/home" do
    it "should have the content 'Nocturia'" do
      visit root_path
      expect(page).to have_content('Nocturia')
    end
  end

  describe "GET /statics/about" do
    it "should have the content 'Nocturia'" do
      visit about_path
      expect(page).to have_content('Nocturia')
    end
  end

end
