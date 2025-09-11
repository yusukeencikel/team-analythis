module PlayersHelper
  def player_age(birthday, season_year)
    return "" if birthday.blank?
    season_year - birthday.year
  end
end