class SettingsController < ApplicationController
  before_action :set_setting, only: [:edit, :update]

  def edit
p "SettingController.edit"
p params
  end

  def update
p "SettingController.update"
p params
p setting_params
    params["setting"]["duration"] = DEFAULT_DURATION if params["setting"]["duration"].to_i == 0
    params["setting"]["startdateymd"] = (Time.now - params["setting"]["duration"].to_i * 24 * 60 * 60).strftime("%Y-%m-%d")
    params["setting"]["enddateymd"] = Time.now.strftime("%Y-%m-%d")
p params
p setting_params
    respond_to do |format|
#      if @setting.update(setting_params)
      if @setting.update(params["setting"].permit(:duration, :startdateymd, :enddateymd))
        flash[:success] = "更新しました。"
        format.html { redirect_to edit_user_setting_path(params[:user_id], params[:id]) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_setting
      @setting = Setting.find(params[:id])
    end

    def setting_params
      params.require(:setting).permit(:duration)
    end
end
