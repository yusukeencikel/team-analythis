    class OcrResult < ApplicationRecord
      # dataカラムを、JSON形式のテキストとして安全に保存・読み込みできるように設定します。
      # Rails 7.1以降の推奨される書き方です。
      serialize :data, coder: JSON
    end
