class BestOrder < ApplicationRecord
  has_many :best_order_players, dependent: :destroy
  has_many :players, through: :best_order_players

  # フォームから送られてきた複数選手のデータを受け付けるための設定
  accepts_nested_attributes_for :best_order_players, allow_destroy: true

  validates :name, presence: true, uniqueness: true
end