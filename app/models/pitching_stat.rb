class PitchingStat < ApplicationRecord
  belongs_to :player
  belongs_to :game

  after_save :update_yearly_stats
  after_destroy :update_yearly_stats

  validate :consistency_of_pitching_stats

  # クオリティ・スタート(QS)を判定するメソッド
  # (先発投手が6回以上を投げて、自責点3以内に抑えた場合にtrueを返す)
  def qs?
    return false unless pitching_order == 1
    return false unless outs_pitched.present? && earned_runs.present?

    outs_pitched >= 18 && earned_runs <= 3
  end

  # ハイ・クオリティ・スタート(HQS)を判定するメソッド
  # (先発投手が7回以上を投げて、自責点2以内に抑えた場合にtrueを返す)
  def hqs?
    return false unless pitching_order == 1
    return false unless outs_pitched.present? && earned_runs.present?

    outs_pitched >= 21 && earned_runs <= 2
  end

  # 完投を判定するメソッド
  def complete_game?
    # 試合の合計アウト数と比較
    return false unless pitching_order == 1 && game.present?
    outs_pitched == game.total_outs
  end
  
  # 完封を判定するメソッド
  def shutout?
    return false unless complete_game?
    earned_runs == 0
  end
  
  # 無四球完投を判定するメソッド
  def no_walk_complete_game?
    return false unless complete_game?
    # 四球と死球の合計が0であるかを確認
    walks.to_i == 0 
  end

  # ホールドポイントを計算し、カラムにセットするメソッドを追加
  def calculate_and_set_hold_points
    points = 0
    points += holds if holds.present?
    points += saves if saves.present?
    points += 1 if wins.present?
    self.hold_points = points
  end

  # フォームなどから "7.2" のような文字列を受け取ったときに、
  # それをアウトカウント (outs_pitched) に変換してDBに保存するための特別なメソッド
  def innings_pitched=(value)
    return if value.blank? || value.to_s.match?(/[^\d.]/)
    parts = value.to_s.split('.')
    innings = parts[0].to_i
    thirds = parts[1].to_i
    self.outs_pitched = (innings * 3) + thirds
  end

  # DBからアウトカウント (outs_pitched) を読み出し、
  # "7.2" のような表示用の文字列に変換するための特別なメソッド
  def innings_pitched
    return "0.0" unless outs_pitched.present?
    innings = outs_pitched / 3
    thirds = outs_pitched % 3
    "#{innings}.#{thirds}"
  end
  
  # コンストラクタをオーバーライドしてデフォルト値を設定
  def initialize(attributes = {})
    super
    self.pitching_order ||= 9999
    self.pitcher_result ||= '-'
  end

  private

  def update_yearly_stats
    # player or game might be nil during some operations
    return if player.nil? || game.nil?
    YearlyStatUpdater.update_pitching_stats(player, game.game_date.year)
  end

  # バリデーション
  def consistency_of_pitching_stats
    if outs_pitched.present? && outs_pitched < 0
      errors.add(:outs_pitched, "は0以上である必要があります")
    end
  end
end
