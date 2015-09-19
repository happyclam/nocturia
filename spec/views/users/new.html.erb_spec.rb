require 'rails_helper'

RSpec.describe "users/new", type: :view do
  before(:each) do
    assign(:user, User.new(
      :name => "MyString",
      :provider => "MyString",
      :screen_name => "MyString",
      :uid => "MyString"
    ))
  end

  # it "renders new user form" do
  #   render

  #   assert_select "form[action=?][method=?]", users_path, "post" do

  #     assert_select "input#user_name[name=?]", "user[name]"

  #     assert_select "input#user_provider[name=?]", "user[provider]"

  #     assert_select "input#user_screen_name[name=?]", "user[screen_name]"

  #     assert_select "input#user_uid[name=?]", "user[uid]"
  #   end
  # end
end
