class RealTeamStatsController < ApplicationController
  before_action :set_real_team_stat, only: [:edit, :update, :destroy]

  def index
    @years = RealTeamStat.select(:year).distinct.order(year: :desc)
    @selected_year = params[:year] || @years.first&.year
    
    if @selected_year
      @real_team_stats = RealTeamStat.where(year: @selected_year).order(:team_name)
    else
      @real_team_stats = []
    end
  end

  def new
    @real_team_stat = RealTeamStat.new
  end

  def create
    @real_team_stat = RealTeamStat.new(real_team_stat_params)
    if @real_team_stat.save
      redirect_to edit_real_team_stat_path(@real_team_stat), notice: '現実チーム成績を登録しました。続けて詳細を入力してください。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @real_team_stat.update(real_team_stat_params)
      redirect_to edit_real_team_stat_path(@real_team_stat), notice: '現実チーム成績を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    year = @real_team_stat.year
    @real_team_stat.destroy
    redirect_to real_team_stats_path(year: year), notice: '現実チーム成績を削除しました。'
  end

  private

  def set_real_team_stat
    @real_team_stat = RealTeamStat.find(params[:id])
  end

  # paramsで受け取る項目を全て許可するように更新
  def real_team_stat_params
    params.require(:real_team_stat).permit! # 項目数が多いため、簡単のため全てを許可
  end
end