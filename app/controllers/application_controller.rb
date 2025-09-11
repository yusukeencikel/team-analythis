class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_current_season_year
  helper_method :current_season_year

  private

  def set_current_season_year
    # 試合が登録されている最新年を「今シーズン」とする。なければ現在の年。
    @current_season_year = Game.maximum(:game_date)&.year || Date.current.year
  end

  def current_season_year
    @current_season_year
  end
end