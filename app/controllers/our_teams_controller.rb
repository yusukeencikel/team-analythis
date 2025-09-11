class OurTeamsController < ApplicationController
  before_action :set_our_team

  def edit
    # @our_team は before_action で設定される
  end

  def update
    if @our_team.update(our_team_params)
      redirect_to edit_our_team_path(@our_team), notice: 'チーム情報を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_our_team
    # 常に最初のチーム情報を編集対象とする
    @our_team = OurTeam.first_or_create
  end

  def our_team_params
    params.require(:our_team).permit(:name, :short_name, :stadium_id, :icon)
  end
end
