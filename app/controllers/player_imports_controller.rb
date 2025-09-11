class PlayerImportsController < ApplicationController
  def new
    # new.html.erb を表示
  end

  def create
    image = params[:image]
    unless image
      redirect_to new_player_import_path, alert: "画像ファイルを選択してください。"
      return
    end

    # ここでPlayerOcrImporterを呼び出す
    @extracted_players = PlayerOcrImporter.new(image_file: image).extract_players

    if @extracted_players.empty?
      redirect_to new_player_import_path, notice: "画像から選手を検出できませんでした。"
    else
      session[:extracted_players] = @extracted_players
      # 正しいルート 'review_player_imports_path' にリダイレクト
      redirect_to review_player_imports_path
    end
  end

  def show_confirm
    @extracted_players = session[:extracted_players]
    unless @extracted_players
      redirect_to new_player_import_path, alert: "OCRデータが見つかりません。もう一度画像をアップロードしてください。"
    end
    # review.html.erb または show_confirm.html.erb を表示
    # Railsの規約により、アクション名と同じ review.html.erb が自動で選択される
    render :review
  end

  def save_confirm
    players_to_import = params[:players]
    success_count = 0
    error_messages = []

    if players_to_import.present?
      players_to_import.each do |_, player_params|
        next unless player_params[:import] == "1"
        
        # 既存の選手を探し、なければ新しく作成 (重複を防ぐ)
        player = Player.find_or_initialize_by(name: player_params[:name])
        
        # データを更新
        player.assign_attributes(
          jersey_number: player_params[:jersey_number],
          position: player_params[:position]
        )

        if player.save
          success_count += 1
        else
          error_messages << "「#{player.name}」: #{player.errors.full_messages.join(', ')}"
        end
      end
    end
    
    session.delete(:extracted_players)
    
    notice_message = "#{success_count} 人の選手を登録しました。"
    notice_message += " エラー: #{error_messages.join(', ')}" if error_messages.any?
    
    redirect_to players_path, notice: notice_message
  end
end

