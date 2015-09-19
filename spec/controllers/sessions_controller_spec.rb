require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  OmniAuth.config.test_mode = true
  omniauth_hash = { 'provider' => 'withings',
                    'uid' => '1234567',
                    'info' => {
                        'name' => 'natasha',
                        'email' => 'hi@natashatherobot.com',
                        'nickname' => 'NatashaTheRobot'
                    },
                    'credentials' =>
                    {'token'=>'XXXXXXXXXXXXXX',
                     'secret'=>'ZZZZZZZZZZZZZZZ'}
                  }
  OmniAuth.config.add_mock(:withings, omniauth_hash)
 
  describe "GET /auth/:provider/callback" do
    before do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:withings]
    end

    describe "#callback" do
      # it "should successfully create a user" do
      #   expect {
      #     post :callback, provider: :withings
      #   }.to change{ User.count }.by(1)
      # end
 
      # it "should successfully create a session" do
      #   expect(session[:user_id]).to be_nil
      #   post :callback, provider: :withings
      #   expect(session[:user_id]).to be_truthy
      # end
 
      it "should redirect the user to the root url" do
        post :callback, provider: :withings
        expect(response).to redirect_to root_url
      end

    end
  end

end
