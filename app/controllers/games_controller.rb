# app/controllers/games_controller.rb

class GamesController < ApplicationController
  # RecordNotFoundエラーが発生した場合に、record_not_foundメソッドを呼び出す
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  before_action :set_game, only: [:show, :edit, :update, :destroy, :toggle_favorite]
  before_action :load_form_data, only: [:new, :edit, :create, :update]

  def index
    # --- 検索機能 ---
    # 検索フォーム用の選択肢を準備
    @years_for_select = Game.pluck(:game_date).map(&:year).uniq.sort.reverse
    @opponents_for_select = Opponent.order(:name)
    
    # 全ての試合を、日付の降順（新しいものが先）で並べ替えて読み込む
    @games = Game.includes(:opponent, :stadium).order(game_date: :desc)

    # --- 検索条件の適用 ---
    if params[:year].present?
      @games = @games.where("extract(year from game_date) = ?", params[:year])
    end
    if params[:month].present?
      @games = @games.where("extract(month from game_date) = ?", params[:month])
    end
    if params[:opponent_id].present?
      @games = @games.where(opponent_id: params[:opponent_id])
    end
    if params[:result].present?
      @games = @games.where(result: params[:result])
    end
    if params[:home_away].present?
      @games = @games.where(home_away: params[:home_away])
    end
    if params[:favorite] == '1'
      @games = @games.where(is_favorite: true)
    end

    # --- ページネーション機能 ---
    @games = @games.page(params[:page]).per(12)
  end

  def show
    @our_team = OurTeam.first
  end

  def new
    @game = Game.new
    latest_game = Game.order(game_date: :desc).first

    if latest_game
      @game.game_date = latest_game.game_date + 1.day
      @game.opponent_id = latest_game.opponent_id
      @game.home_away = latest_game.home_away
      @game.stadium_id = latest_game.stadium_id
    else
      @game.game_date = Date.today
    end
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      redirect_to @game, notice: '新しい試合を登録しました。続けて成績を入力してください。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @game.update(game_params)
      redirect_to @game, notice: '試合情報を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy
    redirect_to games_path, notice: '試合を削除しました。'
  end

  def toggle_favorite
    @game.toggle!(:is_favorite)
    redirect_back(fallback_location: games_path)
  end
  
  # ▼▼▼【ここを修正】▼▼▼
  # 2つあったOCR用アクションを、正しく動作するこちらに一本化
  def ocr_score
    image = params[:image]
    unless image
      render json: { error: '画像ファイルが見つかりません。' }, status: :bad_request
      return
    end
    
    # ScoreboardOcrImporter を使って画像を解析
    scores = ScoreboardOcrImporter.new(image_file: image).extract_scores

    # 処理結果のハッシュを、JSON形式でブラウザに返す
    render json: scores
  rescue => e
    # 途中でエラーが発生した場合の処理
    Rails.logger.error "OCR処理でエラーが発生しました: #{e.message}"
    render json: { error: "OCR処理中にサーバーエラーが発生しました。" }, status: :internal_server_error
  end
  # ▲▲▲【ここまで修正】▲▲▲

  private

  def set_game
    @game = Game.find(params[:id])
  end
  
  def load_form_data
    @opponents = Opponent.all.order(:name)
    @stadiums = Stadium.all.order(:name)
    @our_team = OurTeam.first
    @opponent_stadiums_map = @opponents.where.not(stadium_id: nil).pluck(:id, :stadium_id).to_h
  end

  def game_params
    params.require(:game).permit(
      :game_date, :day_night, :home_away, :opponent_id, :stadium_id,
      :our_score, :opponent_score,
      :our_hits, :opponent_hits, :our_errors, :opponent_errors,
      our_score_details: [], opponent_score_details: []
    )
  end

  # RecordNotFoundエラーを捕捉したときの処理
  def record_not_found
    redirect_to games_path, alert: 'お探しの試合は見つかりませんでした。'
  end
end