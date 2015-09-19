require 'rails_helper'

RSpec.describe "users/index", type: :view do
  before(:each) do
    assign(:users, [
      User.create!(
        :name => "Name",
        :provider => "Provider",
        :screen_name => "Screen Name",
        :uid => "Uid"
      ),
      User.create!(
        :name => "Name",
        :provider => "Provider",
        :screen_name => "Screen Name",
        :uid => "Uid"
      )
    ])
  end

  # it "renders a list of users" do
  #   render
  #   assert_select "tr>td", :text => "Name".to_s, :count => 2
  #   assert_select "tr>td", :text => "Provider".to_s, :count => 2
  #   assert_select "tr>td", :text => "Screen Name".to_s, :count => 2
  #   assert_select "tr>td", :text => "Uid".to_s, :count => 2
  # end
end
