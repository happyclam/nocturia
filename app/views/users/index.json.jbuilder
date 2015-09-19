json.array!(@users) do |user|
  json.extract! user, :id, :name, :provider, :screen_name, :uid
  json.url user_url(user, format: :json)
end
