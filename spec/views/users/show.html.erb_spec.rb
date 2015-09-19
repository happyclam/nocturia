require 'rails_helper'

RSpec.describe "users/show", type: :view do
  before(:each) do
    @user = assign(:user, User.create!(
      :name => "Name",
      :provider => "Provider",
      :screen_name => "Screen Name",
      :uid => "Uid"
    ))
  end

  # it "renders attributes in <p>" do
  #   render
  #   expect(rendered).to match(/Name/)
  #   expect(rendered).to match(/Provider/)
  #   expect(rendered).to match(/Screen Name/)
  #   expect(rendered).to match(/Uid/)
  # end
end
