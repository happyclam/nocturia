require 'rails_helper'

RSpec.describe "users/edit", type: :view do
  before(:each) do
    @user = assign(:user, User.create!(
      :name => "MyString",
      :provider => "MyString",
      :screen_name => "MyString",
      :uid => "MyString"
    ))
  end

  # it "renders the edit user form" do
  #   render

  #   assert_select "form[action=?][method=?]", user_path(@user), "post" do

  #     assert_select "input#user_name[name=?]", "user[name]"

  #     assert_select "input#user_provider[name=?]", "user[provider]"

  #     assert_select "input#user_screen_name[name=?]", "user[screen_name]"

  #     assert_select "input#user_uid[name=?]", "user[uid]"
  #   end
  # end
end
