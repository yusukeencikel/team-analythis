class SettingsController < ApplicationController
  before_action :set_our_team

  # GET /settings
  # 設定フォームを表示するアクション
  def show
    # @our_team は before_action で設定されるため、このアクションは空でOK
  end

  # PATCH /settings
  # フォームから送信された情報で更新するアクション
  def update
    if @our_team.update(our_team_params)
      redirect_to settings_path, notice: 'チーム情報を更新しました。'
    else
      # バリデーションエラーなどで保存に失敗した場合
      render :show, status: :unprocessable_entity
    end
  end

  private

  # DBから自チームの情報を取得し、存在しない場合は新しいオブジェクトを作成
  def set_our_team
    @our_team = OurTeam.first_or_initialize
  end

  # フォームから送信されたパラメータを安全に受け取るための設定
  def our_team_params
    params.require(:our_team).permit(:name, :stadium_id, :icon)
  end
end

