class Opponent < ApplicationRecord
  # 球場マスタに所属することを定義
  # optional: true は、本拠地が未設定でも良い、という意味
  belongs_to :stadium, optional: true
end