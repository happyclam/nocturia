require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  before {
    visit root_path
  }
  describe "GET /auth/failure" do
    it "should have the content 'Nocturia'" do
      visit auth_failure_path
      expect(page).to have_content('Nocturia')
      expect(page).to have_content('Sign in')      
    end
  end

end
