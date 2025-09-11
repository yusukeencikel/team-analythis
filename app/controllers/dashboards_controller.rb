class DashboardsController < ApplicationController
  before_action :set_current_season

  def show
    # 今シーズンのチーム成績
    @team_summary = calculate_team_summary(@current_season)

    # 今シーズンの詳細打撃・投手成績
    @team_batting_stats = calculate_team_batting_stats(@current_season)
    @team_pitching_stats = calculate_team_pitching_stats(@current_season)

    # 最近3試合の結果
    @recent_games = Game.order(game_date: :desc).limit(3)

    # 個人成績ランキング
    @batting_leaders = calculate_batting_leaders(@current_season)
    @pitching_leaders = calculate_pitching_leaders(@current_season)

    # 好調選手ピックアップ
    @hot_batters = calculate_hot_batters
    @hot_starters = calculate_hot_pitchers('starter')
    @hot_relievers = calculate_hot_pitchers('reliever')

    # 年度別成績
    @yearly_team_summaries = calculate_yearly_team_summaries || []
    @yearly_batting_stats = calculate_yearly_batting_stats || []
    @yearly_pitching_stats = calculate_yearly_pitching_stats || []
  end

  private

  def set_current_season
    @current_season = params[:year] || Game.maximum(:game_date)&.year || Date.today.year
  end

  # 年度別のチームサマリーを計算
  def calculate_yearly_team_summaries
    games_by_year = Game.all.group_by { |game| game.game_date.year }
    
    yearly_data = games_by_year.map do |year, games|
      wins = games.count { |g| g.our_team_win? }
      losses = games.count { |g| g.our_team_loss? }
      draws = games.count { |g| g.draw? }
      winning_percentage = (wins + losses).zero? ? 0.0 : wins.to_f / (wins + losses)

      { year: year, wins: wins, losses: losses, draws: draws, winning_percentage: winning_percentage }
    end.sort_by { |data| data[:year] }.reverse

    yearly_data
  end

  # 年度別のチーム打撃成績を計算
  def calculate_yearly_batting_stats
    yearly_stats = BattingStat.joins(:game).group_by { |stat| stat.game.game_date.year }.map do |year, stats|
      summary = calculate_team_batting_stats_from_collection(stats)
      { year: year }.merge(summary)
    end.sort_by { |data| data[:year] }.reverse
    yearly_stats
  end

  # 年度別のチーム投手成績を計算
  def calculate_yearly_pitching_stats
    yearly_stats = PitchingStat.joins(:game).group_by { |stat| stat.game.game_date.year }.map do |year, stats|
      summary = calculate_team_pitching_stats_from_collection(stats)
      { year: year }.merge(summary)
    end.sort_by { |data| data[:year] }.reverse
    yearly_stats
  end

  def calculate_team_batting_stats_from_collection(batting_stats)
    return {} if batting_stats.empty?
    
    at_bats = batting_stats.sum(&:at_bats)
    hits = batting_stats.sum(&:hits)
    home_runs = batting_stats.sum(&:home_runs)
    rbis = batting_stats.sum(&:rbi)
    runs = batting_stats.sum(&:runs)
    doubles = batting_stats.sum(&:doubles)
    triples = batting_stats.sum(&:triples)
    strikeouts = batting_stats.sum(&:strikeouts)
    walks = batting_stats.sum(&:walks)
    sacrifice_bunts = batting_stats.sum(&:sacrifice_bunts)
    sacrifice_flies = batting_stats.sum(&:sacrifice_flies)
    stolen_bases = batting_stats.sum(&:stolen_bases)
    double_plays = batting_stats.sum(&:double_plays)
    errors = batting_stats.sum(&:fielding_errors)

    total_bases = hits + doubles + (triples * 2) + (home_runs * 3)

    batting_average = at_bats.zero? ? 0.0 : hits.to_f / at_bats
    on_base_percentage = (at_bats + walks + sacrifice_flies).zero? ? 0.0 : (hits + walks).to_f / (at_bats + walks + sacrifice_flies)
    slugging_percentage = at_bats.zero? ? 0.0 : total_bases.to_f / at_bats
    ops = on_base_percentage + slugging_percentage
    iso = slugging_percentage - batting_average
    isod = on_base_percentage - batting_average

    {
      games: batting_stats.map(&:game_id).uniq.count,
      at_bats: at_bats,
      hits: hits,
      home_runs: home_runs,
      rbis: rbis,
      runs: runs,
      doubles: doubles,
      triples: triples,
      total_bases: total_bases,
      strikeouts: strikeouts,
      walks: walks,
      sacrifice_bunts: sacrifice_bunts,
      sacrifice_flies: sacrifice_flies,
      stolen_bases: stolen_bases,
      double_plays: double_plays,
      errors: errors,
      batting_average: batting_average,
      on_base_percentage: on_base_percentage,
      slugging_percentage: slugging_percentage,
      ops: ops,
      iso: iso,
      isod: isod
    }
  end

  def calculate_team_pitching_stats_from_collection(pitching_stats)
    return {} if pitching_stats.empty?

    innings_pitched = pitching_stats.sum(&:outs_pitched).to_f / 3
    hits_allowed = pitching_stats.sum(&:hits_allowed)
    home_runs_allowed = pitching_stats.sum(&:home_runs_allowed)
    strikeouts = pitching_stats.sum(&:strikeouts)
    walks = pitching_stats.sum(&:walks)
    wild_pitches = pitching_stats.sum(&:wild_pitches)
    earned_runs = pitching_stats.sum(&:earned_runs)
    saves = pitching_stats.sum(&:saves)
    holds = pitching_stats.sum(&:holds)
    
    games_pitched = pitching_stats.map(&:game_id).uniq.count
    wins = pitching_stats.sum(&:wins)
    losses = pitching_stats.sum(&:losses)
    quality_starts = pitching_stats.count { |ps| ps.qs? }
    high_quality_starts = pitching_stats.count { |ps| ps.hqs? }

    era = innings_pitched.zero? ? 0.0 : (earned_runs.to_f * 9) / innings_pitched
    strikeout_rate = innings_pitched.zero? ? 0.0 : (strikeouts.to_f * 9) / innings_pitched
    k_bb = walks.zero? ? 0.0 : strikeouts.to_f / walks
    whip = (innings_pitched.zero? ? 0.0 : (hits_allowed + walks).to_f / innings_pitched)

    fip_constant = 3.20 # 一般的なFIP定数
    fip = innings_pitched.zero? ? 0.0 : (((13 * home_runs_allowed) + (3 * walks) - (2 * strikeouts)) / innings_pitched) + fip_constant

    {
      games_pitched: games_pitched,
      wins: wins,
      losses: losses,
      saves: saves,
      holds: holds,
      quality_starts: quality_starts,
      high_quality_starts: high_quality_starts,
      innings_pitched: innings_pitched,
      hits_allowed: hits_allowed,
      home_runs_allowed: home_runs_allowed,
      strikeouts: strikeouts,
      strikeout_rate: strikeout_rate,
      walks: walks,
      wild_pitches: wild_pitches,
      earned_runs: earned_runs,
      era: era,
      k_bb: k_bb,
      whip: whip,
      fip: fip
    }
  end

  # 今シーズンのチームサマリーを計算
  def calculate_team_summary(year)
    games = Game.where('EXTRACT(YEAR FROM game_date) = ?', year)

    wins = games.count { |g| g.our_team_win? }
    losses = games.count { |g| g.our_team_loss? }
    draws = games.count { |g| g.draw? }
    winning_percentage = (wins + losses).zero? ? 0.0 : wins.to_f / (wins + losses)

    batting_stats = calculate_team_batting_stats(year)
    pitching_stats = calculate_team_pitching_stats(year)

    {
      wins: wins,
      losses: losses,
      draws: draws,
      winning_percentage: winning_percentage,
      batting_average: batting_stats[:batting_average] || 0.0,
      era: pitching_stats[:era] || 0.0
    }
  end

  # チームの打撃成績を計算
  def calculate_team_batting_stats(year)
    batting_stats = BattingStat.joins(:game).where('EXTRACT(YEAR FROM games.game_date) = ?', year)
    calculate_team_batting_stats_from_collection(batting_stats)
  end

  # チームの投手成績を計算
  def calculate_team_pitching_stats(year)
    pitching_stats = PitchingStat.joins(:game).where('EXTRACT(YEAR FROM games.game_date) = ?', year)
    calculate_team_pitching_stats_from_collection(pitching_stats)
  end

  # 打撃成績ランキングを計算
  def calculate_batting_leaders(year)
    # 打率リーダー（打席数40以上）
    batting_average_leaders = BattingStat.joins(:game, :player).where('EXTRACT(YEAR FROM games.game_date) = ?', year)
      .group(:player_id, 'players.name').select(Arel.sql('players.name, batting_stats.player_id, SUM(batting_stats.at_bats) as total_at_bats, SUM(batting_stats.hits) as total_hits'))
      .having(Arel.sql('SUM(batting_stats.at_bats) >= 40'))
      .order(Arel.sql('SUM(batting_stats.hits)::float / SUM(batting_stats.at_bats) DESC'))
      .limit(3)

    # 本塁打リーダー
    home_run_leaders = BattingStat.joins(:game, :player).where('EXTRACT(YEAR FROM games.game_date) = ?', year)
      .group(:player_id, 'players.name').select(Arel.sql('players.name, batting_stats.player_id, SUM(batting_stats.home_runs) as total_home_runs'))
      .order(Arel.sql('total_home_runs DESC')).limit(3)

    # 打点リーダー
    rbi_leaders = BattingStat.joins(:game, :player).where('EXTRACT(YEAR FROM games.game_date) = ?', year)
      .group(:player_id, 'players.name').select(Arel.sql('players.name, batting_stats.player_id, SUM(batting_stats.rbi) as total_rbi'))
      .order(Arel.sql('total_rbi DESC')).limit(3)

    # OPSリーダー
    ops_leaders = BattingStat.joins(:game, :player).where('EXTRACT(YEAR FROM games.game_date) = ?', year)
      .group(:player_id, 'players.name').select(Arel.sql('players.name, batting_stats.player_id, SUM(batting_stats.hits) as total_hits, SUM(batting_stats.walks) as total_walks, SUM(batting_stats.at_bats) as total_at_bats, SUM(batting_stats.sacrifice_flies) as total_sacrifice_flies, (SUM(batting_stats.hits) + SUM(batting_stats.doubles) + SUM(batting_stats.triples) * 2 + SUM(batting_stats.home_runs) * 3) as total_bases'))
      .having(Arel.sql('SUM(batting_stats.plate_appearances) >= 40'))
      .order(Arel.sql('(SUM(batting_stats.hits) + SUM(batting_stats.walks))::float / (SUM(batting_stats.at_bats) + SUM(batting_stats.walks) + SUM(batting_stats.sacrifice_flies)) + (SUM(batting_stats.hits) + SUM(batting_stats.doubles) + SUM(batting_stats.triples) * 2 + SUM(batting_stats.home_runs) * 3)::float / SUM(batting_stats.at_bats) DESC'))
      .limit(3)

    {
      batting_average: batting_average_leaders,
      home_runs: home_run_leaders,
      rbi: rbi_leaders,
      ops: ops_leaders
    }
  end

  # 投手成績ランキングを計算
  def calculate_pitching_leaders(year)
    # 勝利数リーダー
    wins_leaders = PitchingStat.joins(:game, :player).where('EXTRACT(YEAR FROM games.game_date) = ?', year)
      .group(:player_id, 'players.name').select(Arel.sql('players.name, pitching_stats.player_id, SUM(pitching_stats.wins) as total_wins'))
      .order(Arel.sql('total_wins DESC')).limit(3)

    # セーブ数リーダー
    saves_leaders = PitchingStat.joins(:game, :player).where('EXTRACT(YEAR FROM games.game_date) = ?', year)
      .group(:player_id, 'players.name').select(Arel.sql('players.name, pitching_stats.player_id, SUM(pitching_stats.saves) as total_saves'))
      .order(Arel.sql('total_saves DESC')).limit(3)

    # 防御率リーダー（投球回数30以上）
    era_leaders = PitchingStat.joins(:game, :player).where('EXTRACT(YEAR FROM games.game_date) = ?', year)
      .group(:player_id, 'players.name').select(Arel.sql('players.name, pitching_stats.player_id, SUM(pitching_stats.earned_runs) as total_earned_runs, SUM(pitching_stats.outs_pitched) as total_outs_pitched'))
      .having(Arel.sql('SUM(pitching_stats.outs_pitched) >= 90'))
      .order(Arel.sql('(SUM(pitching_stats.earned_runs) * 27.0) / SUM(pitching_stats.outs_pitched) ASC'))
      .limit(3)

    # 奪三振リーダー
    strikeout_leaders = PitchingStat.joins(:game, :player).where('EXTRACT(YEAR FROM games.game_date) = ?', year)
      .group(:player_id, 'players.name').select(Arel.sql('players.name, pitching_stats.player_id, SUM(pitching_stats.strikeouts) as total_strikeouts'))
      .order(Arel.sql('total_strikeouts DESC')).limit(3)

    {
      wins: wins_leaders,
      saves: saves_leaders,
      era: era_leaders,
      strike_outs: strikeout_leaders
    }
  end

  # 好調野手（最近6試合）
  def calculate_hot_batters
    games = Game.order(game_date: :desc).limit(6).pluck(:id)
    return [] if games.empty?

    BattingStat.joins(:player).where(game_id: games).group(:player_id, 'players.name').select(Arel.sql('players.name, batting_stats.player_id, SUM(batting_stats.hits) as total_hits, SUM(batting_stats.home_runs) as total_home_runs, SUM(batting_stats.rbi) as total_rbi, SUM(batting_stats.at_bats) as total_at_bats, SUM(batting_stats.walks) as total_walks, SUM(batting_stats.sacrifice_flies) as total_sacrifice_flies, (SUM(batting_stats.hits) + SUM(batting_stats.doubles) + SUM(batting_stats.triples) * 2 + SUM(batting_stats.home_runs) * 3) as total_bases'))
      .having(Arel.sql('SUM(batting_stats.at_bats) > 0'))
      .order(Arel.sql('(SUM(batting_stats.hits) + SUM(batting_stats.walks))::float / (SUM(batting_stats.at_bats) + SUM(batting_stats.walks) + SUM(batting_stats.sacrifice_flies)) + (SUM(batting_stats.hits) + SUM(batting_stats.doubles) + SUM(batting_stats.triples) * 2 + SUM(batting_stats.home_runs) * 3)::float / SUM(batting_stats.at_bats) DESC'))
      .limit(3)
  end

  # 好調投手（先発/中継ぎ）
  def calculate_hot_pitchers(role)
    if role == 'starter'
      games = Game.order(game_date: :desc).limit(3).pluck(:id)
      return [] if games.empty?
      
      # 最近3試合で合計15イニング以上投げた先発投手
      pitchers = PitchingStat.joins(:player).where(game_id: games, pitching_order: 1)
        .group(:player_id, 'players.name')
        .select(Arel.sql('players.name, pitching_stats.player_id, SUM(outs_pitched) as total_outs_pitched, SUM(earned_runs) as total_earned_runs, SUM(wins) as total_wins, SUM(losses) as total_losses, SUM(strikeouts) as total_strikeouts, SUM(hits_allowed) as total_hits_allowed, SUM(walks) as total_walks'))
        .having(Arel.sql('SUM(outs_pitched) >= 45'))
        .order(Arel.sql('SUM(earned_runs) * 27.0 / SUM(outs_pitched) ASC'))
      
    elsif role == 'reliever'
      games = Game.order(game_date: :desc).limit(10).pluck(:id)
      return [] if games.empty?

      # 最近10試合で登板した中継ぎ投手
      pitchers = PitchingStat.joins(:player).where(game_id: games).where.not(pitching_order: 1)
        .group(:player_id, 'players.name')
        .select(Arel.sql('players.name, pitching_stats.player_id, SUM(outs_pitched) as total_outs_pitched, SUM(earned_runs) as total_earned_runs, SUM(wins) as total_wins, SUM(losses) as total_losses, SUM(saves) as total_saves, SUM(holds) as total_holds, SUM(strikeouts) as total_strikeouts, SUM(hits_allowed) as total_hits_allowed, SUM(walks) as total_walks'))
        .having(Arel.sql('SUM(outs_pitched) > 0'))
        .order(Arel.sql('SUM(earned_runs) * 27.0 / SUM(outs_pitched) ASC'))
    end

    return [] if pitchers.nil?

    pitchers.map do |pitcher|
      {
        player_name: pitcher.name,
        era: (pitcher.total_outs_pitched.zero? ? 0.0 : (pitcher.total_earned_runs * 27.0) / pitcher.total_outs_pitched),
        wins: pitcher.total_wins,
        losses: pitcher.total_losses,
        saves: pitcher.try(:total_saves),
        holds: pitcher.try(:total_holds),
        strike_outs: pitcher.try(:total_strikeouts),
        whip: (pitcher.total_outs_pitched.zero? ? 0.0 : (pitcher.total_hits_allowed + pitcher.total_walks).to_f / (pitcher.total_outs_pitched.to_f / 3))
      }
    end.take(3)
  end
end