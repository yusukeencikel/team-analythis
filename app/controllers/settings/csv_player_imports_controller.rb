require 'roo'

class Settings::CsvPlayerImportsController < ApplicationController
  def new
    # app/views/settings/csv_player_imports/new.html.erb を表示
  end

  def create
    file = params[:file]
    unless file
      redirect_to new_settings_csv_player_import_path, alert: "ファイルを選択してください。"
      return
    end

    # ファイル拡張子に応じて処理を分岐
    case File.extname(file.original_filename).downcase
    when '.csv'
      spreadsheet = Roo::CSV.new(file.path)
    when '.xlsx'
      spreadsheet = Roo::Excelx.new(file.path)
    else
      redirect_to new_settings_csv_player_import_path, alert: "CSVまたはXLSX形式のファイルを選択してください。"
      return
    end

    header = spreadsheet.row(1)
    success_count = 0
    error_messages = []

    (2..spreadsheet.last_row).each do |i|
      row_data = spreadsheet.row(i)
      # 空白行をスキップ
      next if row_data.all?(&:blank?)

      row = Hash[[header, row_data].transpose]

      player_name = row["名前"]
      # 名前のないデータはスキップ
      next if player_name.blank?

      # 名前の重複チェック
      if Player.exists?(name: player_name)
        error_messages << "#{player_name}: 選手は既に存在します。"
        next
      end

      player = Player.new(
        name: player_name,
        position: row["ポジション"],
        jersey_number: row["背番号"],
        throwing_hand: row["利き腕"],
        batting_hand: row["打席"],
        join_background: row["入団経緯"],
        status: row["ステータス"] || 'active' # デフォルトは現役
      )

      # 生年月日は yyyymmdd 形式を想定
      birthday_str = row["生年月日"].to_s.gsub(/\D/, '')
      if birthday_str.present? && birthday_str.match?(/^\d{8}$/)
        begin
          player.birthday = Date.strptime(birthday_str, '%Y%m%d')
        rescue Date::Error
          error_messages << "#{player_name}: 生年月日のフォーマットが不正です（#{row["生年月日"]})。"
          next
        end
      elsif birthday_str.present?
        error_messages << "#{player_name}: 生年月日のフォーマットが不正です（#{row["生年月日"]})。"
        next
      end

      if player.save
        success_count += 1
      else
        error_messages << "#{player_name}: #{player.errors.full_messages.join(', ')}"
      end
    end

    flash[:notice] = "#{success_count}件の選手データを取り込みました。"
    if error_messages.any?
      flash[:alert] = "以下のエラーが発生しました:\n" + error_messages.join("\n")
    end

    redirect_to players_path
  rescue => e
    redirect_to new_settings_csv_player_import_path, alert: "取り込み中にエラーが発生しました: #{e.message}"
  end
end
