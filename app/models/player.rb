require 'ostruct'

class Player < ApplicationRecord
  include StatCalculable

  # --- 規定打席関連 ---

  # 指定された年の合計打席数を計算する
  def total_plate_appearances(year)
    # BattingStatから関連するGameの年で絞り込む
    batting_stats.joins(:game)
                 .where("EXTRACT(YEAR FROM games.game_date) = ?", year.to_s)
                 .sum(:plate_appearances)
  end

  # 指定された年に規定打席に到達したかを判定する
  def qualified_for_batting_average?(year)
    # その年のチームの総試合数を取得
    total_games_in_year = Game.where("EXTRACT(YEAR FROM game_date) = ?", year.to_s).count
    # 規定打席数を計算（NPBのルールに基づく）
    required_plate_appearances = total_games_in_year * 3.1

    # 規定打席数に到達しているか
    total_plate_appearances(year) >= required_plate_appearances
  end

  # --- 表示用成績取得 ---

  # 指定された年、または通算の野手成績オブジェクトを返す
  def stats_for(year = nil)
    if year.blank? || year == 'career'
      career_stats_as_object
    else
      season_stats(year)
    end
  end

  # 通算野手成績のハッシュをオブジェクトとして返す
  def career_stats_as_object
    stats_hash = career_stats
    stats_hash.present? ? OpenStruct.new(stats_hash) : nil
  end

  # 指定された年、または通算の投手成績オブジェクトを返す
  def pitching_stats_for(year = nil)
    if year.blank? || year == 'career'
      career_pitching_stats_as_object
    else
      season_pitching_stats(year)
    end
  end

  # 通算投手成績のハッシュをオブジェクトとして返す
  def career_pitching_stats_as_object
    stats_hash = career_pitching_stats
    stats_hash.present? ? OpenStruct.new(stats_hash) : nil
  end

  # --- 規定投球回関連 ---

  # 指定された年に規定投球回に到達したかを判定する
  def qualified_for_era?(year)
    # その年のチームの総試合数を取得
    required_innings = Game.where("EXTRACT(YEAR FROM game_date) = ?", year.to_s).count
    return false if required_innings == 0

    # その年の選手の投球回を取得
    stats = pitching_stats_for(year)
    innings_pitched = stats&.innings_pitched || 0
    
    # 規定投球回に到達しているか
    innings_pitched >= required_innings
  end

  # --- アソシエーション ---
  belongs_to :our_team, optional: true
  has_many :batting_stats, dependent: :destroy
  has_many :pitching_stats, dependent: :destroy
  has_many :games, through: :batting_stats
  has_many :yearly_stats, dependent: :destroy
  has_many :awards, dependent: :destroy

  # --- バリデーション ---
  validates :name, presence: true, uniqueness: true
  validates :jersey_number, numericality: { only_integer: true, allow_blank: true }
  validate :unique_jersey_number_for_active_players

  # --- 定数 ---
  DEPARTURE_REASONS = ['引退', 'トレード', '自由契約', '現役ドラフト', 'メジャー']

  # ===================================================================
  # データ取得メソッド (リファクタリング後)
  # ===================================================================

  # --- 年度別・通算成績 (野手) ---
  def season_stats(year)
    yearly_stats.find_by(year: year, stats_type: 'batting')
  end

  def career_stats
    summarize_career_stats('batting')
  end

  def yearly_batting_stats
    yearly_stats.where(stats_type: 'batting').order(year: :desc)
  end

  # --- 年度別・通算成績 (投手) ---
  def season_pitching_stats(year)
    yearly_stats.find_by(year: year, stats_type: 'pitching')
  end

  def career_pitching_stats
    summarize_career_stats('pitching')
  end

  def yearly_pitching_stats
    yearly_stats.where(stats_type: 'pitching').order(year: :desc)
  end

  # --- 詳細分析 (野手) ---
  def stats_by_opponent(year: nil)
    scoped_stats = year ? batting_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year) : batting_stats
    grouped = scoped_stats.group_by { |stat| stat.game.opponent.name }
    grouped.transform_values { |stats| summarize_batting_stats(stats) }
  end

  def monthly_stats(year: nil)
    scoped_stats = year ? batting_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year) : batting_stats
    grouped = scoped_stats.group_by { |stat| stat.game.game_date.month }
    grouped.transform_values { |stats| summarize_batting_stats(stats) }
  end

  def stats_by_stadium(year: nil)
    scoped_stats = year ? batting_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year) : batting_stats
    grouped = scoped_stats.group_by { |stat| stat.game.stadium&.name || '不明' }
    grouped.transform_values { |stats| summarize_batting_stats(stats) }
  end

  def stats_by_home_away(year: nil)
    scoped_stats = year ? batting_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year) : batting_stats
    grouped = scoped_stats.group_by { |stat| stat.game.home_away }
    grouped.transform_values { |stats| summarize_batting_stats(stats) }
  end

  # --- 詳細分析 (投手) ---
  def pitching_stats_by_opponent(year: nil)
    scoped_stats = year ? pitching_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year) : pitching_stats
    grouped = scoped_stats.group_by { |stat| stat.game.opponent.name }
    grouped.transform_values { |stats| summarize_pitching_stats(stats) }
  end

  def pitching_monthly_stats(year: nil)
    scoped_stats = year ? pitching_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year) : pitching_stats
    grouped = scoped_stats.group_by { |stat| stat.game.game_date.month }
    grouped.transform_values { |stats| summarize_pitching_stats(stats) }
  end

  def pitching_stats_by_stadium(year: nil)
    scoped_stats = year ? pitching_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year) : pitching_stats
    grouped = scoped_stats.group_by { |stat| stat.game.stadium&.name || '不明' }
    grouped.transform_values { |stats| summarize_pitching_stats(stats) }
  end

  def pitching_stats_by_home_away(year: nil)
    scoped_stats = year ? pitching_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year) : pitching_stats
    grouped = scoped_stats.group_by { |stat| stat.game.home_away }
    grouped.transform_values { |stats| summarize_pitching_stats(stats) }
  end

  # --- グラフ用データ ---
  def batting_average_progression(year)
    stats = batting_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year).order('games.game_date ASC')
    return { labels: [], data: [] } if stats.empty?

    cumulative_hits = 0
    cumulative_at_bats = 0
    progress_data = []

    stats.each do |stat|
      cumulative_hits += stat.hits
      cumulative_at_bats += stat.at_bats
      avg = cumulative_at_bats > 0 ? (cumulative_hits.to_f / cumulative_at_bats) : 0
      progress_data << { date: stat.game.game_date, avg: avg }
    end

    sampled_data = progress_data.each_slice(5).map(&:last)
    sampled_data << progress_data.last if progress_data.present? && progress_data.size % 5 != 0

    {
      labels: sampled_data.map { |d| d[:date].strftime('%-m/%-d') },
      data: sampled_data.map { |d| d[:avg] }
    }
  end

  def era_progression(year)
    stats = pitching_stats.joins(:game).where("EXTRACT(YEAR FROM games.game_date) = ?", year).order('games.game_date ASC')
    return { labels: [], data: [] } if stats.empty?

    cumulative_earned_runs = 0
    cumulative_outs_pitched = 0
    progress_data = []

    stats.each do |stat|
      cumulative_earned_runs += stat.earned_runs
      cumulative_outs_pitched += stat.outs_pitched

      total_innings_pitched = cumulative_outs_pitched.to_f / 3
      era = total_innings_pitched > 0 ? (cumulative_earned_runs.to_f * 9) / total_innings_pitched : 0.0
      progress_data << { date: stat.game.game_date, era: era }
    end
    
    sampled_data = progress_data.each_slice(5).map(&:last)
    sampled_data << progress_data.last if progress_data.present? && progress_data.size % 5 != 0

    {
      labels: sampled_data.map { |d| d[:date].strftime('%-m/%-d') },
      data: progress_data.map { |d| d[:era] }
    }
  end

  # --- 最近の試合 ---
  def recent_games_stats(limit = 6)
    batting_stats.joins(:game).order('games.game_date DESC').limit(limit)
  end

  # --- 登板経験の有無を判定 ---
  def has_pitching_stats?
    pitching_stats.exists?
  end

  def cumulative_pitcher_record_up_to(game)
    stats = pitching_stats.joins(:game).where("games.game_date <= ?", game.game_date)
    wins = stats.where(pitcher_result: '勝利').count
    losses = stats.where(pitcher_result: '敗戦').count
    saves = stats.where(pitcher_result: 'セーブ').count
    "#{wins}勝#{losses}敗#{saves}S"
  end

  def cumulative_home_runs_up_to(game)
    batting_stats.joins(:game).where("games.game_date < ?", game.game_date).sum(:home_runs)
  end

  def cumulative_batting_average_up_to(game)
    stats = batting_stats.joins(:game).where("games.game_date <= ?", game.game_date)
    total_hits = stats.sum(:hits)
    total_at_bats = stats.sum(:at_bats)
    return ".000" if total_at_bats == 0
    format('%.3f', total_hits.to_f / total_at_bats).sub(/^0/, '')
  end

  def cumulative_earned_run_average_up_to(game)
    stats = pitching_stats.joins(:game).where("games.game_date <= ?", game.game_date)
    total_earned_runs = stats.sum(:earned_runs)
    total_outs_pitched = stats.sum(:outs_pitched)
    return "0.00" if total_outs_pitched == 0
    era = (total_earned_runs.to_f * 27) / total_outs_pitched
    format('%.2f', era)
  end

  private

  def unique_jersey_number_for_active_players
    # 背番号が空、または退団選手の場合はチェックしない
    return if jersey_number.blank? || status == 'inactive'

    # 自分以外の現役選手で同じ背番号がいないかチェック
    if Player.where(status: 'active').where.not(id: id).exists?(jersey_number: jersey_number)
      errors.add(:jersey_number, 'は他の現役選手が使用しています')
    end
  end

  def summarize_career_stats(stats_type)
    stats_collection = yearly_stats.where(stats_type: stats_type)
    return {} if stats_collection.empty?

    batting_attrs_to_sum = %i[games plate_appearances at_bats runs hits doubles triples home_runs rbi stolen_bases walks strikeouts sacrifice_bunts sacrifice_flies double_plays fielding_errors total_bases]
    pitching_attrs_to_sum = %i[appearances starts complete_games shutouts no_walk_complete_games wins losses saves holds outs_pitched hits_allowed home_runs_allowed runs_allowed earned_runs walks_allowed strikeouts_pitched wild_pitches qs hqs]
    
    attrs_to_sum = stats_type == 'batting' ? batting_attrs_to_sum : pitching_attrs_to_sum

    raw_stats = attrs_to_sum.each_with_object({}) do |attr, hash|
      hash[attr] = stats_collection.sum(attr)
    end

    if stats_type == 'batting'
      add_calculated_batting_metrics(raw_stats)
    else
      add_calculated_pitching_metrics(raw_stats)
    end
  end
end