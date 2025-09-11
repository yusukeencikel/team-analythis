# app/models/yearly_stat.rb
class YearlyStat < ApplicationRecord
  belongs_to :player
  
  # 投手用と野手用の両方のフィールドがあるか、またはstats_typeで区別されている
  validates :year, presence: true
  validates :stats_type, presence: true
  
  # 必要なフィールドのバリデーションなど
end