class BattingStat < ApplicationRecord
  belongs_to :game
  belongs_to :player

  after_initialize :set_defaults, if: :new_record?
  after_save :update_yearly_stats
  after_destroy :update_yearly_stats

  # --- バリデーション ---
  validate :consistency_of_batting_stats

  private

  def update_yearly_stats
    # playerかgameがnilの場合は何もしない
    return if player.nil? || game.nil?
    YearlyStatUpdater.update_batting_stats(player, game.game_date.year)
  end

  def consistency_of_batting_stats
    # 各数値がnil(空)の場合はチェックをスキップする
    return if at_bats.nil? || hits.nil? || doubles.nil? || triples.nil? || home_runs.nil?

    # 1. 安打数は、打数を超えることはない
    if hits > at_bats
      errors.add(:hits, "は打数を超えることはできません")
    end

    # 2. 長打の合計は、総安打数を超えることはない
    if (doubles + triples + home_runs) > hits
      errors.add(:base, "二塁打、三塁打、本塁打の合計は総安打数を超えることはできません")
    end
  end
  
  def set_defaults
    self.at_bats ||= 0
    self.hits ||= 0
    self.doubles ||= 0
    self.triples ||= 0
    self.home_runs ||= 0
    self.rbi ||= 0
    self.runs ||= 0
    self.strikeouts ||= 0
    self.walks ||= 0
    self.sacrifice_bunts ||= 0
    self.sacrifice_flies ||= 0
    self.stolen_bases ||= 0
    self.double_plays ||= 0
    self.fielding_errors ||= 0
  end
end
