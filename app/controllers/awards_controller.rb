class AwardsController < ApplicationController
  def index
    game_years = Game.all.pluck(:game_date).compact.map(&:year).uniq
    award_years = Award.distinct.pluck(:year)
    @years = (game_years + award_years).uniq.sort.reverse
  end

  def show
    @year = params[:id]
    @awards = Award.where(year: @year).includes(:player).group_by(&:name)
  end

  def new
    @year = Time.now.year
  end

  def create
    year = params[:award][:year]
    redirect_to edit_award_path(year)
  end

  def edit
    @year = params[:id]
    @players = Player.where(status: 'active').order(:name)
    @awards = Award.where(year: @year).includes(:player).group_by(&:name)

    @batter_titles = ["首位打者", "本塁打王", "打点王", "最多安打", "盗塁王", "最高出塁率", "最高OPS"]
    @pitcher_titles = ["最優秀防御率", "最多勝", "最高勝率", "最多奪三振", "最優秀中継ぎ", "最多セーブ", "沢村賞"]
    @common_titles = ["MVP"]
    @golden_glove_positions = ["投手", "捕手", "一塁手", "二塁手", "三塁手", "遊撃手", "外野手", "外野手", "外野手"]
    @best_nine_positions = ["投手", "捕手", "一塁手", "二塁手", "三塁手", "遊撃手", "外野手", "外野手", "外野手", "DH"]
  end

  def update
    @year = params[:id]
    awards_params = params.require(:awards).permit!

    Award.transaction do
      Award.where(year: @year).destroy_all

      awards_params.each do |title, player_id|
        next if player_id.blank?
        
        if player_id.is_a?(Array)
          player_id.each do |p_id|
            Award.create!(year: @year, name: title, player_id: p_id) if p_id.present?
          end
        else
          Award.create!(year: @year, name: title, player_id: player_id)
        end
      end
    end

    redirect_to award_path(@year), notice: 'タイトル受賞者を更新しました。'
  rescue => e
    redirect_to edit_award_path(@year), alert: "更新に失敗しました: #{e.message}"
  end
end