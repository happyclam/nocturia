class UsersController < ApplicationController
  before_action :set_user, only: [:destroy, :paint, :prev_page, :next_page, :last_page]

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def prev_page
p "users.prev_page"
    @user.setting.enddateymd = @user.setting.startdateymd
    @user.setting.startdateymd =
      (Date.strptime(@user.setting.startdateymd, "%Y-%m-%d") - @user.setting.duration).strftime("%Y-%m-%d")
    results = @user.get_sleep_summary(@user.setting.startdateymd, @user.setting.enddateymd, session)
    @count = results["body"]["series"].count
    if @count.to_i > 0
      @user.setting.save
      @graph_data, @average = @user.draw_graph(results)
      render :paint
    else
      redirect_to paint_user_path(@user), notice: 'これより以前のデータはありません'
      return
    end

  end

  def next_page
p "users.next_page"
    @user.setting.startdateymd = @user.setting.enddateymd
    @user.setting.enddateymd =
      (Date.strptime(@user.setting.enddateymd, "%Y-%m-%d") + @user.setting.duration).strftime("%Y-%m-%d")
    results = @user.get_sleep_summary(@user.setting.startdateymd, @user.setting.enddateymd, session)
    @count = results["body"]["series"].count
    #startとendに同日を設定した場合は、現在のDBの設定で表示
    if @count > 1
      @user.setting.save
      @graph_data, @average = @user.draw_graph(results)
      render :paint
    else
      redirect_to paint_user_path(@user), notice: '次のデータはありません'
      return
    end
  end

  def last_page
p "users.last_page"
    @user.setting.enddateymd = Time.now.strftime("%Y-%m-%d")
    @user.setting.startdateymd = (Time.now - @user.setting.duration * 24 * 60 * 60).strftime("%Y-%m-%d")
    results = @user.get_sleep_summary(@user.setting.startdateymd, @user.setting.enddateymd, session)
    @count = results["body"]["series"].count
    if @count > 0
      @user.setting.save
      @graph_data, @average = @user.draw_graph(results)
      render :paint
    else
      redirect_to paint_user_path(@user), notice: '次のデータはありません'
      return
    end
  end

  def paint
p "users.paint"
p @user.setting
    begin
      results = @user.get_sleep_summary(@user.setting.startdateymd, @user.setting.enddateymd, session)
#pp results
      @count = results["body"]["series"].count
      @graph_data, @average = @user.draw_graph(results)

    rescue
      p $!
      #APIでデータ取得失敗はACCESS_TOKENまたはセッションの期限切れに決め打ち
      session[:user_id] = nil
      session[:access_token] = nil
      session[:access_token_secret] = nil
      flash[:notice] = "許可証の期限が切れました。Sign inをやり直してください"
      redirect_to root_url
      return
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :provider, :screen_name, :uid)
    end
end
