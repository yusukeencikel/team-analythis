class Game < ApplicationRecord
  # --- アソシエーション（関連付け） ---
  has_many :pitching_stats, class_name: 'PitchingStat', dependent: :destroy
  has_many :batting_stats, class_name: 'BattingStat', dependent: :destroy

  belongs_to :opponent
  belongs_to :stadium, optional: true

  # --- バリデーション ---
  validates :game_date, presence: true
  validates :opponent_id, presence: true
  validates :home_away, presence: true
  validates :our_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :opponent_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # --- スコープ ---
  scope :for_year, ->(year) { where("extract(year from game_date) = ?", year) }

  # --- ヘルパーメソッド ---
  before_save :set_result

  def our_team_win?
    result == 'win'
  end
  
  def our_team_loss?
    result == 'lose'
  end
  
  def draw?
    result == 'draw'
  end
  
  # ▼▼▼【ここから修正】▼▼▼
  # 試合の合計アウト数を正確に計算
  def total_outs
    our_innings = our_score_details.reject(&:blank?).size
    opponent_innings = opponent_score_details.reject(&:blank?).size
    
    # 後攻がサヨナラ勝ちした場合、裏の攻撃は完了していない
    if home_away == '後攻' && our_score > opponent_score && our_innings >= 9
      (our_innings - 1) * 3
    else
      [our_innings, opponent_innings].max * 3
    end
  end
  # ▲▲▲【ここまで修正】▲▲▲

  def set_result
    return if our_score.nil? || opponent_score.nil?

    if our_score > opponent_score
      self.result = 'win'
    elsif our_score < opponent_score
      self.result = 'lose'
    else
      self.result = 'draw'
    end
  end
  
  def winning_pitcher
    pitching_stats.find_by(pitcher_result: '勝利')&.player
  end

  def losing_pitcher
    pitching_stats.find_by(pitcher_result: '敗戦')&.player
  end

  def saving_pitcher
    pitching_stats.find_by(pitcher_result: 'セーブ')&.player
  end
  
  def home_run_hitters
    batting_stats.includes(:player).where("home_runs > 0")
  end
  
  def sorted_pitching_stats
    pitching_stats.includes(:player).order(pitching_order: :asc)
  end
  
  def sorted_batting_stats
    batting_stats.includes(:player).where.not(batting_order: nil).order(batting_order: :asc)
  end

  def total_innings
    [our_score_details&.reject(&:blank?)&.size || 0, opponent_score_details&.reject(&:blank?)&.size || 0, 9].max
  end
  
  def our_display_scores
    generate_display_scores(our_score_details || [], opponent_score_details || [], home_away == '後攻')
  end

  def opponent_display_scores
    generate_display_scores(opponent_score_details || [], our_score_details || [], home_away == '先攻')
  end

  def our_team_hits
    batting_stats.joins(:player).where.not(players: { our_team_id: nil }).sum(:hits)
  end

  def opponent_team_hits
    batting_stats.joins(:player).where(players: { our_team_id: nil }).sum(:hits)
  end

  def our_team_errors
    batting_stats.joins(:player).where.not(players: { our_team_id: nil }).sum(:fielding_errors)
  end

  def opponent_team_errors
    batting_stats.joins(:player).where(players: { our_team_id: nil }).sum(:fielding_errors)
  end

  private

  def generate_display_scores(scores_array, opponent_scores_array, is_home_team)
    scores_raw = scores_array || []
    opponent_scores_raw = opponent_scores_array || []

    scores = scores_raw.reverse.drop_while { |s| s.to_s.strip.empty? }.reverse
    opponent_scores = opponent_scores_raw.reverse.drop_while { |s| s.to_s.strip.empty? }.reverse

    display_scores = scores.map(&:to_s)
    
    numeric_scores = scores.map(&:to_i)
    numeric_opponent_scores = opponent_scores.map(&:to_i)
    
    if is_home_team
      numeric_scores.each_with_index do |score, i|
        next if i < 8
        
        our_cumulative_score = numeric_scores.first(i + 1).sum
        opponent_final_score = numeric_opponent_scores.sum
        
        if our_cumulative_score > opponent_final_score
          display_scores[i] = "#{scores[i]}x"
          return display_scores.first(i + 1)
        end
      end

      if opponent_scores.size >= 9 && scores.size < opponent_scores.size && numeric_scores.sum > numeric_opponent_scores.sum
        display_scores << "x"
      end
    end
    
    display_scores
  end
end