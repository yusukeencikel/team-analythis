class RealPlayerStatsController < ApplicationController
  before_action :set_real_player_stat, only: [:edit, :update, :destroy]

  def index
    @years = RealPlayerStat.select(:year).distinct.order(year: :desc)
    @selected_year = params[:year] || @years.first&.year

    if @selected_year
      @real_player_stats = RealPlayerStat.where(year: @selected_year).order(:player_name)
    else
      @real_player_stats = []
    end
  end

  def new
    @real_player_stat = RealPlayerStat.new
  end

  def create
    @real_player_stat = RealPlayerStat.new(real_player_stat_params)
    if @real_player_stat.save
      redirect_to edit_real_player_stat_path(@real_player_stat), notice: '現実選手成績を登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @real_player_stat.update(real_player_stat_params)
      redirect_to edit_real_player_stat_path(@real_player_stat), notice: '現実選手成績を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    year = @real_player_stat.year
    @real_player_stat.destroy
    redirect_to real_player_stats_path(year: year), notice: '現実選手成績を削除しました。'
  end

  private

  def set_real_player_stat
    @real_player_stat = RealPlayerStat.find(params[:id])
  end

  def real_player_stat_params
    params.require(:real_player_stat).permit! # 項目数が多いため全て許可
  end
end