require "pp"
class SessionsController < ApplicationController
  def callback
p "SessionController.callback"
#    raise request.env["omniauth.auth"].to_yaml
    begin
      auth = request.env["omniauth.auth"]
#pp auth
#pp auth.extra.access_token.params
#p auth.extra.access_token.params[:deviceid]
      user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
      session[:user_id] = user.id
      session[:access_token] = auth.credentials.token if auth
      session[:access_token_secret] = auth.credentials.secret if auth
    rescue ActiveRecord::RecordInvalid
      flash[:notice] = "login failed (既に存在します)"
#    rescue
#      p $!
    else
      flash[:notice] = "login succeeded"
    ensure
      redirect_to root_url
      return
    end
  end

  def destroy
    session[:user_id] = nil
    session[:access_token] = nil
    session[:access_token_secret] = nil
    redirect_to root_url, :notice => "logout succeeded"
    return
  end
end
