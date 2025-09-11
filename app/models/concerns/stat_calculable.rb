# app/models/concerns/stat_calculable.rb
module StatCalculable
  extend ActiveSupport::Concern

  def summarize_batting_stats(stats_collection)
    return {} if stats_collection.empty?

    raw_stats = {
      games: stats_collection.map(&:game_id).uniq.size,
      plate_appearances: stats_collection.map(&:plate_appearances).compact.sum,
      at_bats: stats_collection.map(&:at_bats).compact.sum,
      hits: stats_collection.map(&:hits).compact.sum,
      doubles: stats_collection.map(&:doubles).compact.sum,
      triples: stats_collection.map(&:triples).compact.sum,
      home_runs: stats_collection.map(&:home_runs).compact.sum,
      rbi: stats_collection.map(&:rbi).compact.sum,
      runs: stats_collection.map(&:runs).compact.sum,
      strikeouts: stats_collection.map(&:strikeouts).compact.sum,
      walks: stats_collection.map(&:walks).compact.sum,
      sacrifice_bunts: stats_collection.map(&:sacrifice_bunts).compact.sum,
      sacrifice_flies: stats_collection.map(&:sacrifice_flies).compact.sum,
      stolen_bases: stats_collection.map(&:stolen_bases).compact.sum,
      double_plays: stats_collection.map(&:double_plays).compact.sum,
      fielding_errors: stats_collection.map(&:fielding_errors).compact.sum,
    }
    add_calculated_batting_metrics(raw_stats)
  end

  def summarize_pitching_stats(stats_collection)
    return {} if stats_collection.empty?
    
    raw_stats = {
      appearances: stats_collection.size,
      wins: stats_collection.count { |stat| stat.pitcher_result == '勝利' },
      losses: stats_collection.count { |stat| stat.pitcher_result == '敗戦' },
      saves: stats_collection.count { |stat| stat.pitcher_result == 'セーブ' },
      holds: stats_collection.count { |stat| stat.pitcher_result == 'ホールド' },
      outs_pitched: stats_collection.map(&:outs_pitched).compact.sum,
      hits_allowed: stats_collection.map(&:hits_allowed).compact.sum,
      home_runs_allowed: stats_collection.map(&:home_runs_allowed).compact.sum,
      strikeouts_pitched: stats_collection.map(&:strikeouts).compact.sum,
      walks_allowed: stats_collection.map(&:walks).compact.sum,
      runs_allowed: stats_collection.map(&:runs_allowed).compact.sum,
      earned_runs: stats_collection.map(&:earned_runs).compact.sum,
      wild_pitches: stats_collection.map(&:wild_pitches).compact.sum,
      qs: stats_collection.count(&:qs?),
      hqs: stats_collection.count(&:hqs?),
      starts: stats_collection.count { |stat| stat.pitching_order == 1 },
      complete_games: stats_collection.count(&:complete_game?),
      shutouts: stats_collection.count(&:shutout?),
      no_walk_complete_games: stats_collection.count(&:no_walk_complete_game?)
    }
    add_calculated_pitching_metrics(raw_stats)
  end

  def add_calculated_batting_metrics(stats)
    at_bats = stats[:at_bats].to_f
    hits = stats[:hits].to_f
    walks = stats[:walks].to_f
    sacrifice_flies = stats[:sacrifice_flies].to_f
    doubles = stats[:doubles].to_f
    triples = stats[:triples].to_f
    home_runs = stats[:home_runs].to_f

    batting_average = at_bats > 0 ? hits / at_bats : 0
    total_bases = hits + doubles + (triples * 2) + (home_runs * 3)

    obp_numerator = hits + walks
    obp_denominator = at_bats + walks + sacrifice_flies
    on_base_percentage = obp_denominator > 0 ? obp_numerator / obp_denominator : 0

    slugging_percentage = at_bats > 0 ? total_bases / at_bats : 0
    ops = on_base_percentage + slugging_percentage
    iso = slugging_percentage - batting_average
    isod = on_base_percentage - batting_average

    stats.merge(
      total_bases: total_bases.to_i,
      batting_average: batting_average,
      on_base_percentage: on_base_percentage,
      slugging_percentage: slugging_percentage,
      ops: ops,
      iso: iso,
      isod: isod
    )
  end

  def add_calculated_pitching_metrics(stats)
    outs_pitched = stats[:outs_pitched].to_f
    earned_runs = stats[:earned_runs].to_f
    starts = stats[:starts].to_f
    strikeouts = stats[:strikeouts_pitched].to_f
    walks = stats[:walks_allowed].to_f
    hits_allowed = stats[:hits_allowed].to_f
    home_runs_allowed = stats[:home_runs_allowed].to_f

    total_innings_pitched = outs_pitched / 3
    era = total_innings_pitched > 0 ? (earned_runs * 9) / total_innings_pitched : 0.0
    qs_rate = starts > 0 ? stats[:qs].to_f / starts : 0.0
    hqs_rate = starts > 0 ? stats[:hqs].to_f / starts : 0.0
    k_per_nine = total_innings_pitched > 0 ? (strikeouts * 9) / total_innings_pitched : 0.0
    k_bb = walks > 0 ? strikeouts / walks : 0.0
    whip = total_innings_pitched > 0 ? (walks + hits_allowed) / total_innings_pitched : 0.0
    
    fip_constant = 3.20
    fip = total_innings_pitched > 0 ? (((13 * home_runs_allowed) + (3 * walks) - (2 * strikeouts)) / total_innings_pitched) + fip_constant : 0.0

    stats.merge(
      era: era,
      qs_rate: qs_rate,
      hqs_rate: hqs_rate,
      whip: whip,
      k_per_nine: k_per_nine,
      k_bb: k_bb,
      fip: fip,
      innings_pitched: total_innings_pitched
    )
  end
end
